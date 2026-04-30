const axios = require("axios");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const crypto = require("crypto");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

admin.initializeApp();

const USERS_COLLECTION = "users";
const PROD_VERIFY_RECEIPT_URL = "https://buy.itunes.apple.com/verifyReceipt";
const SANDBOX_VERIFY_RECEIPT_URL = "https://sandbox.itunes.apple.com/verifyReceipt";

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  return request.auth.uid;
}

function allowedProductIds() {
  const raw = process.env.IAP_PRODUCT_IDS || "ai_image_pro";
  return new Set(
    raw
      .split(",")
      .map((id) => id.trim())
      .filter(Boolean),
  );
}

function tokenDigest(value) {
  if (!value) return "missing";
  return crypto.createHash("sha256").update(value).digest("hex").slice(0, 12);
}

function subscriptionEndTimestamp(result) {
  if (!result.expiryDate) return null;
  const parsed = new Date(result.expiryDate);
  if (Number.isNaN(parsed.getTime())) return null;
  return admin.firestore.Timestamp.fromDate(parsed);
}

async function persistEntitlement(uid, verification) {
  const endTimestamp = subscriptionEndTimestamp(verification);
  const nowTs = admin.firestore.FieldValue.serverTimestamp();
  const entitlementStatus = verification.isActive ? "premium" : "free";

  const data = {
    subscriptionStatus: entitlementStatus,
    productId: verification.productId || null,
    purchaseToken: verification.purchaseToken || null,
    orderId: verification.orderId || null,
    basePlanId: verification.basePlanId || null,
    subscriptionStartDate: verification.isActive
      ? admin.firestore.Timestamp.now()
      : null,
    subscriptionEndDate: endTimestamp,
    expiryDate: endTimestamp,
    autoRenewing: !!verification.autoRenewing,
    priceAmount: verification.priceAmount ?? null,
    priceCurrencyCode: verification.priceCurrencyCode ?? null,
    billingPeriod: verification.billingPeriod ?? null,
    verifiedPlatform: verification.platform,
    verificationProvider: verification.verificationProvider,
    lastVerificationAt: nowTs,
    updatedAt: nowTs,
  };

  await admin
    .firestore()
    .collection(USERS_COLLECTION)
    .doc(uid)
    .set(data, { merge: true });
}

async function verifyAndroidSubscription({
  purchaseToken,
  packageName,
}) {
  if (!purchaseToken) {
    throw new HttpsError("invalid-argument", "Missing Android purchase token.");
  }

  const resolvedPackageName =
    packageName || process.env.ANDROID_PACKAGE_NAME || "com.tarurinfotech.reducer";

  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });

  const publisher = google.androidpublisher({
    version: "v3",
    auth,
  });

  const { data } = await publisher.purchases.subscriptionsv2.get({
    packageName: resolvedPackageName,
    token: purchaseToken,
  });

  const lineItem = Array.isArray(data.lineItems) ? data.lineItems[0] : null;
  const expiryTime = lineItem?.expiryTime || null;
  const subscriptionState = data.subscriptionState || "SUBSCRIPTION_STATE_UNKNOWN";
  const autoRenewEnabled = lineItem?.autoRenewingPlan?.autoRenewEnabled ?? false;

  const activeStates = new Set([
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  ]);

  return {
    platform: "android",
    isActive: activeStates.has(subscriptionState),
    productId: lineItem?.productId || null,
    purchaseToken,
    orderId: data.latestOrderId || null,
    basePlanId: lineItem?.offerDetails?.basePlanId || null,
    expiryDate: expiryTime,
    autoRenewing: autoRenewEnabled,
    priceAmount: null,
    priceCurrencyCode: null,
    billingPeriod: null,
    verificationProvider: "google_play_subscriptions_v2",
  };
}

function pickLatestReceipt(receipts) {
  if (!Array.isArray(receipts) || receipts.length === 0) return null;
  return receipts.reduce((latest, current) => {
    const latestMs = Number(latest?.expires_date_ms || 0);
    const currentMs = Number(current?.expires_date_ms || 0);
    return currentMs > latestMs ? current : latest;
  }, receipts[0]);
}

async function callAppleVerifyReceipt(body, url) {
  return axios.post(url, body, {
    timeout: 10000,
    headers: {
      "Content-Type": "application/json",
    },
  });
}

async function verifyIosSubscription({
  receiptData,
  bundleId,
}) {
  if (!receiptData) {
    throw new HttpsError("invalid-argument", "Missing iOS receipt data.");
  }

  const sharedSecret = process.env.APPLE_SHARED_SECRET;
  if (!sharedSecret) {
    throw new HttpsError(
      "failed-precondition",
      "Server missing APPLE_SHARED_SECRET.",
    );
  }

  const expectedBundleId =
    bundleId || process.env.IOS_BUNDLE_ID || "com.tarurinfotech.reducer";

  const body = {
    "receipt-data": receiptData,
    password: sharedSecret,
    "exclude-old-transactions": true,
  };

  let response = await callAppleVerifyReceipt(body, PROD_VERIFY_RECEIPT_URL);

  // Status 21007 means the receipt is from sandbox but sent to production.
  if (response.data?.status === 21007) {
    response = await callAppleVerifyReceipt(body, SANDBOX_VERIFY_RECEIPT_URL);
  }

  if (response.data?.status !== 0) {
    throw new HttpsError(
      "permission-denied",
      `Apple verification failed with status ${response.data?.status}.`,
    );
  }

  const receiptBundleId = response.data?.receipt?.bundle_id;
  if (receiptBundleId && receiptBundleId !== expectedBundleId) {
    throw new HttpsError("permission-denied", "Bundle ID mismatch.");
  }

  const latest = pickLatestReceipt(response.data?.latest_receipt_info);
  if (!latest) {
    throw new HttpsError("permission-denied", "No valid iOS receipt items found.");
  }

  const expiryMs = Number(latest.expires_date_ms || 0);
  const canceled = !!latest.cancellation_date || !!latest.cancellation_date_ms;
  const nowMs = Date.now();
  const isActive = !canceled && expiryMs > nowMs;

  const renewalInfo = Array.isArray(response.data?.pending_renewal_info)
    ? response.data.pending_renewal_info
    : [];
  const autoRenewing = renewalInfo.some((item) => item?.auto_renew_status === "1");

  return {
    platform: "ios",
    isActive,
    productId: latest.product_id || null,
    purchaseToken: latest.original_transaction_id || latest.transaction_id || null,
    orderId: latest.transaction_id || null,
    basePlanId: null,
    expiryDate: expiryMs > 0 ? new Date(expiryMs).toISOString() : null,
    autoRenewing,
    priceAmount: null,
    priceCurrencyCode: null,
    billingPeriod: null,
    verificationProvider: "apple_verify_receipt",
  };
}

async function verifyByPlatform(platform, payload) {
  if (platform === "android") {
    return verifyAndroidSubscription({
      purchaseToken: payload.purchaseToken,
      packageName: payload.packageName,
    });
  }
  if (platform === "ios") {
    return verifyIosSubscription({
      receiptData: payload.receiptData,
      bundleId: payload.bundleId,
    });
  }
  throw new HttpsError("invalid-argument", "Unsupported platform.");
}

exports.verifySubscription = onCall(async (request) => {
  const uid = requireAuth(request);
  const data = request.data || {};
  const platform = typeof data.platform === "string" ? data.platform.toLowerCase() : "";
  const requestedProductId =
    typeof data.productId === "string" ? data.productId.trim() : "";

  if (!platform) {
    throw new HttpsError("invalid-argument", "platform is required.");
  }

  if (requestedProductId) {
    const allowed = allowedProductIds();
    if (!allowed.has(requestedProductId)) {
      throw new HttpsError("permission-denied", "Product ID is not allowed.");
    }
  }

  try {
    const verification = await verifyByPlatform(platform, data);
    if (requestedProductId && verification.productId && requestedProductId !== verification.productId) {
      throw new HttpsError(
        "permission-denied",
        "Verified product does not match requested product.",
      );
    }

    await persistEntitlement(uid, verification);

    return {
      ok: true,
      isActive: verification.isActive,
      subscriptionStatus: verification.isActive ? "premium" : "free",
      platform: verification.platform,
      productId: verification.productId,
      expiryDate: verification.expiryDate,
    };
  } catch (error) {
    logger.error("verifySubscription failed", {
      uid,
      platform,
      productId: requestedProductId || null,
      purchaseDigest: tokenDigest(data.purchaseToken || data.receiptData || ""),
      code: error?.code || "unknown",
      message: error?.message || "unknown",
    });
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", "Subscription verification failed.");
  }
});

exports.verifyStoredSubscription = onCall(async (request) => {
  const uid = requireAuth(request);

  const userDoc = await admin
    .firestore()
    .collection(USERS_COLLECTION)
    .doc(uid)
    .get();

  if (!userDoc.exists) {
    throw new HttpsError("failed-precondition", "User profile not found.");
  }

  const user = userDoc.data() || {};
  const platform = (user.verifiedPlatform || request.data?.platform || "").toString().toLowerCase();
  const purchaseToken = user.purchaseToken || null;

  if (!platform || !purchaseToken) {
    throw new HttpsError(
      "failed-precondition",
      "No stored subscription token available for verification.",
    );
  }

  try {
    const verification = await verifyByPlatform(platform, {
      purchaseToken,
      receiptData: request.data?.receiptData || null,
      packageName: request.data?.packageName || null,
      bundleId: request.data?.bundleId || null,
    });
    await persistEntitlement(uid, verification);

    return {
      ok: true,
      isActive: verification.isActive,
      subscriptionStatus: verification.isActive ? "premium" : "free",
      platform: verification.platform,
      productId: verification.productId,
      expiryDate: verification.expiryDate,
    };
  } catch (error) {
    logger.error("verifyStoredSubscription failed", {
      uid,
      platform,
      purchaseDigest: tokenDigest(purchaseToken),
      code: error?.code || "unknown",
      message: error?.message || "unknown",
    });
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", "Stored subscription verification failed.");
  }
});
