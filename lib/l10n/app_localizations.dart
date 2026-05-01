import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @searchLanguage.
  ///
  /// In en, this message translates to:
  /// **'Search Language...'**
  String get searchLanguage;

  /// No description provided for @welcomeToReducer.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Reducer'**
  String get welcomeToReducer;

  /// No description provided for @setupLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language to get started with the best image optimization experience.'**
  String get setupLanguageSubtitle;

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'REDUCER'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Studio'**
  String get homeTitle;

  /// No description provided for @bulkStudio.
  ///
  /// In en, this message translates to:
  /// **'Bulk Studio'**
  String get bulkStudio;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @singleEditor.
  ///
  /// In en, this message translates to:
  /// **'Single Editor'**
  String get singleEditor;

  /// No description provided for @startBatchProcessing.
  ///
  /// In en, this message translates to:
  /// **'Start Batch Processing'**
  String get startBatchProcessing;

  /// No description provided for @selectImages.
  ///
  /// In en, this message translates to:
  /// **'Select Images'**
  String get selectImages;

  /// No description provided for @saveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to Gallery'**
  String get saveToGallery;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @compressionSuccess.
  ///
  /// In en, this message translates to:
  /// **'✓ Saved to Gallery!'**
  String get compressionSuccess;

  /// No description provided for @freeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'Free users: limit 50 images. Upgrade for more.'**
  String get freeLimitMessage;

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @optimizeImage.
  ///
  /// In en, this message translates to:
  /// **'Optimize Image'**
  String get optimizeImage;

  /// No description provided for @optimizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce size while maintaining quality'**
  String get optimizeSubtitle;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @convertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PNG, WebP, etc.'**
  String get convertSubtitle;

  /// No description provided for @historySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recent edits'**
  String get historySubtitle;

  /// No description provided for @advancedTools.
  ///
  /// In en, this message translates to:
  /// **'Advanced Tools'**
  String get advancedTools;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @bulkProcessing.
  ///
  /// In en, this message translates to:
  /// **'Bulk Processing'**
  String get bulkProcessing;

  /// No description provided for @bulkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Process up to 50 images at once'**
  String get bulkSubtitle;

  /// No description provided for @exifEraser.
  ///
  /// In en, this message translates to:
  /// **'EXIF Eraser'**
  String get exifEraser;

  /// No description provided for @exifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove metadata for privacy'**
  String get exifSubtitle;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'Edit History'**
  String get viewHistory;

  /// No description provided for @viewHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and export past edits'**
  String get viewHistorySubtitle;

  /// No description provided for @unlockReducerPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock Reducer Pro'**
  String get unlockReducerPro;

  /// No description provided for @unlockAllProFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock All Pro Features'**
  String get unlockAllProFeatures;

  /// No description provided for @proDescription.
  ///
  /// In en, this message translates to:
  /// **'Bulk processing and ad-free experience are available for Pro members. Join our community today!'**
  String get proDescription;

  /// No description provided for @promoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk processing, no ads, high quality export & more.'**
  String get promoSubtitle;

  /// No description provided for @upgradeToPro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeToPro;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @compress.
  ///
  /// In en, this message translates to:
  /// **'Compress'**
  String get compress;

  /// No description provided for @resize.
  ///
  /// In en, this message translates to:
  /// **'Resize'**
  String get resize;

  /// No description provided for @format.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get format;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @processImage.
  ///
  /// In en, this message translates to:
  /// **'Process Image'**
  String get processImage;

  /// No description provided for @showBefore.
  ///
  /// In en, this message translates to:
  /// **'Show Before'**
  String get showBefore;

  /// No description provided for @showAfter.
  ///
  /// In en, this message translates to:
  /// **'Show After'**
  String get showAfter;

  /// No description provided for @originalSize.
  ///
  /// In en, this message translates to:
  /// **'Original size'**
  String get originalSize;

  /// No description provided for @compressed.
  ///
  /// In en, this message translates to:
  /// **'Compressed'**
  String get compressed;

  /// No description provided for @dimensions.
  ///
  /// In en, this message translates to:
  /// **'Dimensions'**
  String get dimensions;

  /// No description provided for @readyToExport.
  ///
  /// In en, this message translates to:
  /// **'Ready to export!'**
  String get readyToExport;

  /// No description provided for @applyChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'Apply your changes and click \"Process Image\" to generate your final result.'**
  String get applyChangesMessage;

  /// No description provided for @itemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed from history'**
  String get itemRemoved;

  /// No description provided for @selectOutputFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Output Format'**
  String get selectOutputFormat;

  /// No description provided for @formatDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the file type that best fits your needs'**
  String get formatDescription;

  /// No description provided for @targetFileSize.
  ///
  /// In en, this message translates to:
  /// **'Target File Size'**
  String get targetFileSize;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image Quality'**
  String get imageQuality;

  /// No description provided for @smallerFile.
  ///
  /// In en, this message translates to:
  /// **'Smaller file'**
  String get smallerFile;

  /// No description provided for @higherQuality.
  ///
  /// In en, this message translates to:
  /// **'Higher quality'**
  String get higherQuality;

  /// No description provided for @sizeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2.5'**
  String get sizeHint;

  /// No description provided for @customDimensions.
  ///
  /// In en, this message translates to:
  /// **'Custom Dimensions'**
  String get customDimensions;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @lockAspectRatio.
  ///
  /// In en, this message translates to:
  /// **'Lock aspect ratio'**
  String get lockAspectRatio;

  /// No description provided for @aspectRatioMaintained.
  ///
  /// In en, this message translates to:
  /// **'Aspect ratio maintained'**
  String get aspectRatioMaintained;

  /// No description provided for @transform.
  ///
  /// In en, this message translates to:
  /// **'Transform'**
  String get transform;

  /// No description provided for @flipHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Flip horizontal'**
  String get flipHorizontal;

  /// No description provided for @pickImageToStart.
  ///
  /// In en, this message translates to:
  /// **'Pick an image to start'**
  String get pickImageToStart;

  /// No description provided for @pickImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose from your gallery or take a new photo'**
  String get pickImageSubtitle;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String failedToSave(String error);

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share: {error}'**
  String failedToShare(String error);

  /// No description provided for @processingDot.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processingDot;

  /// No description provided for @shareWithReducer.
  ///
  /// In en, this message translates to:
  /// **'Processed with Reducer'**
  String get shareWithReducer;

  /// No description provided for @batchOptimizationComplete.
  ///
  /// In en, this message translates to:
  /// **'BATCH OPTIMIZATION COMPLETE'**
  String get batchOptimizationComplete;

  /// No description provided for @smaller.
  ///
  /// In en, this message translates to:
  /// **'Smaller'**
  String get smaller;

  /// No description provided for @freeUserLimit.
  ///
  /// In en, this message translates to:
  /// **'Free users: limit 50 images. Upgrade for more.'**
  String get freeUserLimit;

  /// No description provided for @batchProcessing.
  ///
  /// In en, this message translates to:
  /// **'Batch Processing'**
  String get batchProcessing;

  /// No description provided for @batchDescription.
  ///
  /// In en, this message translates to:
  /// **'Optimize hundreds of images in one go'**
  String get batchDescription;

  /// No description provided for @selectMultipleImages.
  ///
  /// In en, this message translates to:
  /// **'Select Multiple Images'**
  String get selectMultipleImages;

  /// No description provided for @bulkSettingsNote.
  ///
  /// In en, this message translates to:
  /// **'Settings will be applied to ALL selected images.'**
  String get bulkSettingsNote;

  /// No description provided for @bulkResizeNote.
  ///
  /// In en, this message translates to:
  /// **'Percentage scaling is recommended for bulk batches.'**
  String get bulkResizeNote;

  /// No description provided for @bulkFormatNote.
  ///
  /// In en, this message translates to:
  /// **'All converted images will be saved in the selected format.'**
  String get bulkFormatNote;

  /// No description provided for @autoQualityActive.
  ///
  /// In en, this message translates to:
  /// **'Automatic Quality Mode Active: Quality slider will be ignored to hit your target size.'**
  String get autoQualityActive;

  /// No description provided for @scalePercentRecommended.
  ///
  /// In en, this message translates to:
  /// **'Scale % (Recommended)'**
  String get scalePercentRecommended;

  /// No description provided for @chooseOutputFormat.
  ///
  /// In en, this message translates to:
  /// **'Choose Output Format'**
  String get chooseOutputFormat;

  /// No description provided for @bestForPhotos.
  ///
  /// In en, this message translates to:
  /// **'Best for photos'**
  String get bestForPhotos;

  /// No description provided for @bestForGraphics.
  ///
  /// In en, this message translates to:
  /// **'Best for graphics'**
  String get bestForGraphics;

  /// No description provided for @modernAndSmall.
  ///
  /// In en, this message translates to:
  /// **'Modern & Small'**
  String get modernAndSmall;

  /// No description provided for @uncompressed.
  ///
  /// In en, this message translates to:
  /// **'Uncompressed'**
  String get uncompressed;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @fixedDimensionsExpert.
  ///
  /// In en, this message translates to:
  /// **'Fixed Dimensions (Expert)'**
  String get fixedDimensionsExpert;

  /// No description provided for @totalOriginal.
  ///
  /// In en, this message translates to:
  /// **'Total Original'**
  String get totalOriginal;

  /// No description provided for @totalCompressed.
  ///
  /// In en, this message translates to:
  /// **'Total Compressed'**
  String get totalCompressed;

  /// No description provided for @spaceSaved.
  ///
  /// In en, this message translates to:
  /// **'Space Saved'**
  String get spaceSaved;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @zip.
  ///
  /// In en, this message translates to:
  /// **'ZIP'**
  String get zip;

  /// No description provided for @processingProgress.
  ///
  /// In en, this message translates to:
  /// **'Processing ({percent}%)...'**
  String processingProgress(int percent);

  /// No description provided for @savedXImages.
  ///
  /// In en, this message translates to:
  /// **'✓ Saved {count} images!'**
  String savedXImages(int count);

  /// No description provided for @zipError.
  ///
  /// In en, this message translates to:
  /// **'ZIP error: {error}'**
  String zipError(String error);

  /// No description provided for @processedImages.
  ///
  /// In en, this message translates to:
  /// **'Processed images'**
  String get processedImages;

  /// No description provided for @galleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get galleryEmpty;

  /// No description provided for @noPastEdits.
  ///
  /// In en, this message translates to:
  /// **'No past edits found'**
  String get noPastEdits;

  /// No description provided for @galleryEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Process and export images\nto see them here'**
  String get galleryEmptyDescription;

  /// No description provided for @startNewEdit.
  ///
  /// In en, this message translates to:
  /// **'Start New Edit'**
  String get startNewEdit;

  /// No description provided for @unableToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Unable to load history right now'**
  String get unableToLoadHistory;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear History?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all past edits from history. This action cannot be undone.'**
  String get clearHistoryMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @savedImages.
  ///
  /// In en, this message translates to:
  /// **'Saved {count} images!'**
  String savedImages(int count);

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @upgradeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features & remove ads'**
  String get upgradeSubtitle;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'Reducer Pro Active'**
  String get proActive;

  /// No description provided for @supportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get supportThanks;

  /// No description provided for @supportAndFeedback.
  ///
  /// In en, this message translates to:
  /// **'Support & Feedback'**
  String get supportAndFeedback;

  /// No description provided for @rateOnPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Rate on Play Store'**
  String get rateOnPlayStore;

  /// No description provided for @shareReducer.
  ///
  /// In en, this message translates to:
  /// **'Share Reducer'**
  String get shareReducer;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @profileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated!'**
  String get profileImageUpdated;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed: {error}'**
  String uploadFailed(String error);

  /// No description provided for @imagesStudio.
  ///
  /// In en, this message translates to:
  /// **'Images Studio'**
  String get imagesStudio;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @freeMember.
  ///
  /// In en, this message translates to:
  /// **'Free Member'**
  String get freeMember;

  /// No description provided for @basicToolsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Basic tools enabled'**
  String get basicToolsEnabled;

  /// No description provided for @goPro.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get goPro;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Ready to leave? Your progress is safely synced to the cloud.'**
  String get logOutConfirmation;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @accountStudio.
  ///
  /// In en, this message translates to:
  /// **'Account Studio'**
  String get accountStudio;

  /// No description provided for @startSession.
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Reducer Image Studio v{version}'**
  String appVersionLabel(String version);

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(Object error);

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google Sign-In failed: {error}'**
  String googleSignInFailed(Object error);

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Please check your inbox.'**
  String get passwordResetSent;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue using Reducer'**
  String get loginContinue;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordLengthError;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(Object error);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinAndStart.
  ///
  /// In en, this message translates to:
  /// **'Join Reducer and start creating'**
  String get joinAndStart;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// No description provided for @nameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameLengthError;

  /// No description provided for @passwordComplexityError.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number or special character'**
  String get passwordComplexityError;

  /// No description provided for @passwordLengthErrorRegister.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordLengthErrorRegister;

  /// No description provided for @registerWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Register with Google'**
  String get registerWithGoogle;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @premiumMembership.
  ///
  /// In en, this message translates to:
  /// **'PRO MEMBERSHIP'**
  String get premiumMembership;

  /// No description provided for @eliteMember.
  ///
  /// In en, this message translates to:
  /// **'Elite Member'**
  String get eliteMember;

  /// No description provided for @fullAccessActive.
  ///
  /// In en, this message translates to:
  /// **'Full access to Reducer Studio is active on your account.'**
  String get fullAccessActive;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @nextBilling.
  ///
  /// In en, this message translates to:
  /// **'Next Billing'**
  String get nextBilling;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @proAccess.
  ///
  /// In en, this message translates to:
  /// **'PRO ACCESS'**
  String get proAccess;

  /// No description provided for @unlockStudio.
  ///
  /// In en, this message translates to:
  /// **'Unlock the Full Studio'**
  String get unlockStudio;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get high-performance tools, AI upscaling,\nand an absolute ad-free experience.'**
  String get premiumSubtitle;

  /// No description provided for @featureBulkStudio.
  ///
  /// In en, this message translates to:
  /// **'Bulk Studio (Batch Resize & Export)'**
  String get featureBulkStudio;

  /// No description provided for @featureAiTurbo.
  ///
  /// In en, this message translates to:
  /// **'AI Turbo Upscaling & Clean'**
  String get featureAiTurbo;

  /// No description provided for @featureZeroAds.
  ///
  /// In en, this message translates to:
  /// **'Zero Ads. Absolute Privacy.'**
  String get featureZeroAds;

  /// No description provided for @featureDirectZip.
  ///
  /// In en, this message translates to:
  /// **'Direct ZIP & 4K Collections'**
  String get featureDirectZip;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @unlockPro.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro'**
  String get unlockPro;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. Secure checkout.'**
  String get cancelAnytime;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available at the moment.'**
  String get noPlansAvailable;

  /// No description provided for @tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later or contact support.'**
  String get tryAgainLater;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get errorOccurred;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'SELECT PLAN'**
  String get selectPlan;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'SAVES {percent}%'**
  String savePercent(String percent);

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'{days} Days Free Trial'**
  String freeTrial(String days);

  /// No description provided for @clearHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove all past edits from history. This action cannot be undone.'**
  String get clearHistoryContent;

  /// No description provided for @historyLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load history right now'**
  String get historyLoadError;

  /// No description provided for @imageActions.
  ///
  /// In en, this message translates to:
  /// **'Image Actions'**
  String get imageActions;

  /// No description provided for @shareImage.
  ///
  /// In en, this message translates to:
  /// **'Share Image'**
  String get shareImage;

  /// No description provided for @savedToGallerySuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery!'**
  String get savedToGallerySuccess;

  /// No description provided for @processedFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Processed file not found'**
  String get processedFileNotFound;

  /// No description provided for @bulkCountLabel.
  ///
  /// In en, this message translates to:
  /// **'BULK ({count})'**
  String bulkCountLabel(Object count);

  /// No description provided for @resultSummary.
  ///
  /// In en, this message translates to:
  /// **'RESULT SUMMARY'**
  String get resultSummary;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'OUTPUT'**
  String get output;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'SAVED'**
  String get saved;

  /// No description provided for @formatLabel.
  ///
  /// In en, this message translates to:
  /// **'FORMAT'**
  String get formatLabel;

  /// No description provided for @optimizationComplete.
  ///
  /// In en, this message translates to:
  /// **'Optimization Complete! 🎉'**
  String get optimizationComplete;

  /// No description provided for @bulkOptimizationResult.
  ///
  /// In en, this message translates to:
  /// **'Reduced {count} images: {original} → {compressed} ({reduction}% smaller)'**
  String bulkOptimizationResult(
    int count,
    String original,
    String compressed,
    String reduction,
  );

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large ({size} MB).\nMaximum size is 50MB.'**
  String imageTooLarge(Object size);

  /// No description provided for @largeFileWarning.
  ///
  /// In en, this message translates to:
  /// **'Large file detected. Processing may take longer.'**
  String get largeFileWarning;

  /// No description provided for @imageDimensionsTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image dimensions too large ({width}x{height}).\nMaximum is 10000x10000 pixels.'**
  String imageDimensionsTooLarge(Object height, Object width);

  /// No description provided for @cannotDecodeImage.
  ///
  /// In en, this message translates to:
  /// **'Cannot decode image.\nFile may be corrupted or invalid format.'**
  String get cannotDecodeImage;

  /// No description provided for @errorReadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error reading image: {error}'**
  String errorReadingImage(Object error);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @continueAnyway.
  ///
  /// In en, this message translates to:
  /// **'Continue Anyway'**
  String get continueAnyway;

  /// No description provided for @bulkSessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Bulk Session Details'**
  String get bulkSessionDetails;

  /// No description provided for @xImagesProcessed.
  ///
  /// In en, this message translates to:
  /// **'{count} Images Processed'**
  String xImagesProcessed(Object count);

  /// No description provided for @loadingImages.
  ///
  /// In en, this message translates to:
  /// **'Loading images...'**
  String get loadingImages;

  /// No description provided for @noImagesFoundInSession.
  ///
  /// In en, this message translates to:
  /// **'No images found in this session'**
  String get noImagesFoundInSession;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get signInRequired;

  /// No description provided for @signInRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'To access pro features and sync your edits across devices, please sign in to your account.'**
  String get signInRequiredDescription;

  /// No description provided for @signInNow.
  ///
  /// In en, this message translates to:
  /// **'Sign In Now'**
  String get signInNow;

  /// No description provided for @loginRequiredForPremium.
  ///
  /// In en, this message translates to:
  /// **'Login required for Premium'**
  String get loginRequiredForPremium;

  /// No description provided for @guestModePremiumMessage.
  ///
  /// In en, this message translates to:
  /// **'You are using guest mode. Login to subscribe, restore purchases, and unlock Pro tools.'**
  String get guestModePremiumMessage;

  /// No description provided for @subscribeWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Subscribe {price} / {period}'**
  String subscribeWithPrice(String price, String period);

  /// No description provided for @startProAccess.
  ///
  /// In en, this message translates to:
  /// **'START PRO ACCESS'**
  String get startProAccess;

  /// No description provided for @trialPeriodText.
  ///
  /// In en, this message translates to:
  /// **'Start with {period} free trial'**
  String trialPeriodText(String period);

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'YEARLY'**
  String get yearly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY'**
  String get monthly;

  /// No description provided for @trial.
  ///
  /// In en, this message translates to:
  /// **'TRIAL'**
  String get trial;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @yearSuffix.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get yearSuffix;

  /// No description provided for @monthSuffix.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get monthSuffix;

  /// No description provided for @freeLabel.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get freeLabel;

  /// No description provided for @permissionRequiredToAccessPhotos.
  ///
  /// In en, this message translates to:
  /// **'Permission required to access photos'**
  String get permissionRequiredToAccessPhotos;

  /// No description provided for @unableToOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Unable to open gallery: {error}'**
  String unableToOpenGallery(Object error);

  /// No description provided for @storagePermissionRequiredToSave.
  ///
  /// In en, this message translates to:
  /// **'Storage permission required to save'**
  String get storagePermissionRequiredToSave;

  /// No description provided for @failedToCleanMetadata.
  ///
  /// In en, this message translates to:
  /// **'Failed to clean metadata'**
  String get failedToCleanMetadata;

  /// No description provided for @errorCleaningMetadata.
  ///
  /// In en, this message translates to:
  /// **'Error cleaning metadata: {error}'**
  String errorCleaningMetadata(Object error);

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @exifSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Sensitive metadata has been completely removed. The clean image is now safe in your Gallery under the \"Reducer\" folder.'**
  String get exifSuccessMessage;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @freeTrialLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} Free Trial Left'**
  String freeTrialLeft(int count);

  /// No description provided for @privacyFirst.
  ///
  /// In en, this message translates to:
  /// **'Privacy First'**
  String get privacyFirst;

  /// No description provided for @privacyFirstDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove GPS coordinates, camera info, and other sensitive metadata from your photos before sharing.'**
  String get privacyFirstDescription;

  /// No description provided for @cleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning...'**
  String get cleaning;

  /// No description provided for @cleanAndSave.
  ///
  /// In en, this message translates to:
  /// **'Clean & Save'**
  String get cleanAndSave;

  /// No description provided for @tapToSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to select image'**
  String get tapToSelectImage;

  /// No description provided for @poweredByAi.
  ///
  /// In en, this message translates to:
  /// **'POWERED BY AI'**
  String get poweredByAi;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @madeWithHeart.
  ///
  /// In en, this message translates to:
  /// **'Made with ♥ by Tarur Infotech'**
  String get madeWithHeart;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: April 05, 2026'**
  String get lastUpdated;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Data Processing'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Content.
  ///
  /// In en, this message translates to:
  /// **'All image processing occurs locally on your device. We do not upload, store, or transmit your photos to any external servers. Your images remain completely private and secure on your device.'**
  String get privacySection1Content;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Information Collection'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Content.
  ///
  /// In en, this message translates to:
  /// **'We collect minimal anonymous usage data to improve the app experience. This includes crash reports and basic analytics. No personally identifiable information is collected without your explicit consent.'**
  String get privacySection2Content;

  /// No description provided for @privacySectionTitle3.
  ///
  /// In en, this message translates to:
  /// **'3. Third-Party Services'**
  String get privacySectionTitle3;

  /// No description provided for @privacySectionContent3.
  ///
  /// In en, this message translates to:
  /// **'We use Google AdMob for displaying advertisements (in the free version) and RevenueCat for managing subscriptions. These services may collect information as outlined in their respective privacy policies.'**
  String get privacySectionContent3;

  /// No description provided for @privacySectionTitle4.
  ///
  /// In en, this message translates to:
  /// **'4. Device Permissions'**
  String get privacySectionTitle4;

  /// No description provided for @privacySectionContent4.
  ///
  /// In en, this message translates to:
  /// **'We require photo/storage access solely for the purpose of selecting images to edit and saving the processed results. We do not access any other files on your device.'**
  String get privacySectionContent4;

  /// No description provided for @privacySectionTitle5.
  ///
  /// In en, this message translates to:
  /// **'5. Contact Us'**
  String get privacySectionTitle5;

  /// No description provided for @privacySectionContent5.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about this Privacy Policy, please contact us at tarurinfotech@gmail.com.'**
  String get privacySectionContent5;

  /// No description provided for @shareAppText.
  ///
  /// In en, this message translates to:
  /// **'Check out Reducer - The ultimate image compression and processing tool! Download here: {url}'**
  String shareAppText(String url);

  /// No description provided for @signInBenefit.
  ///
  /// In en, this message translates to:
  /// **'Sign in to unlock cross-device sync,\nPro features, and your history.'**
  String get signInBenefit;

  /// No description provided for @fullAccessUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Full access unlocked'**
  String get fullAccessUnlocked;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Ready to leave? Your progress is safely synced to the cloud.'**
  String get logoutConfirm;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get accountDeletedSuccess;

  /// No description provided for @deleteAccountReauthNeeded.
  ///
  /// In en, this message translates to:
  /// **'Deletion failed. For security, you may need to log out and log back in before deleting your account.'**
  String get deleteAccountReauthNeeded;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @successPurchase.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium! 🎉'**
  String get successPurchase;

  /// No description provided for @successRestore.
  ///
  /// In en, this message translates to:
  /// **'Restored Successfully!'**
  String get successRestore;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @noProcessedImageYet.
  ///
  /// In en, this message translates to:
  /// **'No processed image yet'**
  String get noProcessedImageYet;

  /// No description provided for @processImageFirstHint.
  ///
  /// In en, this message translates to:
  /// **'Go to the Settings tab and tap \"Process Image\".'**
  String get processImageFirstHint;

  /// No description provided for @beforeOriginal.
  ///
  /// In en, this message translates to:
  /// **'Before (Original)'**
  String get beforeOriginal;

  /// No description provided for @afterProcessed.
  ///
  /// In en, this message translates to:
  /// **'After (Processed)'**
  String get afterProcessed;

  /// No description provided for @comparePreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Processed image preview'**
  String get comparePreviewLabel;

  /// No description provided for @holdImageToCompare.
  ///
  /// In en, this message translates to:
  /// **'Hold image to compare'**
  String get holdImageToCompare;

  /// No description provided for @sizeReducedLabel.
  ///
  /// In en, this message translates to:
  /// **'Size Reduced'**
  String get sizeReducedLabel;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'et',
    'fr',
    'hi',
    'id',
    'ja',
    'ko',
    'pl',
    'pt',
    'ru',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
