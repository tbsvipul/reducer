// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get continueLabel => '계속하기';

  @override
  String get searchLanguage => '언어 검색...';

  @override
  String get welcomeToReducer => 'Reducer에 오신 것을 환영합니다';

  @override
  String get setupLanguageSubtitle => '최상의 이미지 최적화 경험을 시작하기 위해 선호하는 언어를 선택하세요.';

  @override
  String get appTitle => 'REDUCER';

  @override
  String get homeTitle => '스튜디오';

  @override
  String get bulkStudio => '벌크 스튜디오';

  @override
  String get history => '기록';

  @override
  String get profile => '프로필';

  @override
  String get singleEditor => '단일 편집기';

  @override
  String get startBatchProcessing => '일괄 처리 시작';

  @override
  String get selectImages => '이미지 선택';

  @override
  String get saveToGallery => '갤러리에 저장';

  @override
  String get share => '공유하기';

  @override
  String get processing => '처리 중...';

  @override
  String get settings => '설정';

  @override
  String get premium => '프리미엄';

  @override
  String get compressionSuccess => '✓ 갤러리에 저장되었습니다!';

  @override
  String get freeLimitMessage => '무료 사용자: 50장 제한. 더 많이 사용하려면 업그레이드하세요.';

  @override
  String get quickStart => '빠른 시작';

  @override
  String get howItWorks => '작동 방식';

  @override
  String get optimizeImage => '이미지 최적화';

  @override
  String get optimizeSubtitle => '품질은 유지하면서 용량 줄이기';

  @override
  String get convert => '변환';

  @override
  String get convertSubtitle => 'PNG, WebP 등';

  @override
  String get historySubtitle => '최근 편집';

  @override
  String get advancedTools => '고급 도구';

  @override
  String get proBadge => 'PRO';

  @override
  String get bulkProcessing => '일괄 처리';

  @override
  String get bulkSubtitle => '한 번에 최대 50장 처리';

  @override
  String get exifEraser => 'EXIF 지우개';

  @override
  String get exifSubtitle => '개인정보 보호를 위한 메타데이터 제거';

  @override
  String get viewHistory => '편집 기록';

  @override
  String get viewHistorySubtitle => '과거 편집 내역 보기 및 내보내기';

  @override
  String get unlockReducerPro => 'Reducer Pro 잠금 해제';

  @override
  String get unlockAllProFeatures => '모든 Pro 기능 사용하기';

  @override
  String get proDescription =>
      '일괄 처리 및 광고 없는 환경은 Pro 멤버에게만 제공됩니다. 오늘 바로 커뮤니티에 가입하세요!';

  @override
  String get promoSubtitle => '일괄 처리, 광고 없음, 고화질 내보내기 등.';

  @override
  String get upgradeToPro => 'Pro로 업그레이드';

  @override
  String get upgradeNow => '지금 업그레이드';

  @override
  String get maybeLater => '나중에 하기';

  @override
  String get compress => '압축';

  @override
  String get resize => '크기 조정';

  @override
  String get format => '형식';

  @override
  String get export => '내보내기';

  @override
  String get processImage => '이미지 처리';

  @override
  String get showBefore => '원본 보기';

  @override
  String get showAfter => '결과 보기';

  @override
  String get originalSize => '원본 크기';

  @override
  String get compressed => '압축됨';

  @override
  String get dimensions => '해상도';

  @override
  String get readyToExport => '내보낼 준비가 되었습니다!';

  @override
  String get applyChangesMessage => '변경 사항을 적용하고 \"이미지 처리\"를 눌러 최종 결과를 만드세요.';

  @override
  String get itemRemoved => '기록에서 삭제되었습니다';

  @override
  String get selectOutputFormat => '출력 형식 선택';

  @override
  String get formatDescription => '필요에 가장 적합한 파일 형식을 선택하세요';

  @override
  String get targetFileSize => '목표 파일 크기';

  @override
  String get imageQuality => '이미지 품질';

  @override
  String get smallerFile => '용량 우선';

  @override
  String get higherQuality => '품질 우선';

  @override
  String get sizeHint => '예: 2.5';

  @override
  String get customDimensions => '사용자 지정 해상도';

  @override
  String get width => '너비';

  @override
  String get height => '높이';

  @override
  String get lockAspectRatio => '비율 고정';

  @override
  String get aspectRatioMaintained => '비율이 유지됩니다';

  @override
  String get transform => '변형';

  @override
  String get flipHorizontal => '좌우 반전';

  @override
  String get pickImageToStart => '시작할 이미지를 선택하세요';

  @override
  String get pickImageSubtitle => '갤러리에서 선택하거나 새로 촬영하세요';

  @override
  String get gallery => '갤러리';

  @override
  String get camera => '카메라';

  @override
  String failedToSave(String error) {
    return '저장 실패: $error';
  }

  @override
  String failedToShare(String error) {
    return '공유 실패: $error';
  }

  @override
  String get processingDot => '처리 중...';

  @override
  String get shareWithReducer => 'Reducer로 처리됨';

  @override
  String get batchOptimizationComplete => '일괄 최적화 완료';

  @override
  String get smaller => '절약됨';

  @override
  String get freeUserLimit => '무료 사용자: 50장 제한. 더 사용하려면 업그레이드하세요.';

  @override
  String get batchProcessing => '일괄 처리';

  @override
  String get batchDescription => '수백 장의 이미지를 한 번에 최적화';

  @override
  String get selectMultipleImages => '여러 이미지 선택';

  @override
  String get bulkSettingsNote => '설정은 선택한 모든 이미지에 적용됩니다.';

  @override
  String get bulkResizeNote => '일괄 처리 시 비율(%) 조정이 권장됩니다.';

  @override
  String get bulkFormatNote => '변환된 모든 이미지는 선택한 형식으로 저장됩니다.';

  @override
  String get autoQualityActive => '자동 품질 모드 활성화: 목표 크기에 맞추기 위해 품질 슬라이더가 무시됩니다.';

  @override
  String get scalePercentRecommended => '비율 % (권장)';

  @override
  String get chooseOutputFormat => '출력 형식 선택';

  @override
  String get bestForPhotos => '사진에 최적';

  @override
  String get bestForGraphics => '그래픽에 최적';

  @override
  String get modernAndSmall => '최신 형식 & 저용량';

  @override
  String get uncompressed => '압축 안 함';

  @override
  String get original => '원본';

  @override
  String get fixedDimensionsExpert => '고정 해상도 (전문가용)';

  @override
  String get totalOriginal => '총 원본 크기';

  @override
  String get totalCompressed => '총 압축 크기';

  @override
  String get spaceSaved => '저장된 공간';

  @override
  String get saveAll => '모두 저장';

  @override
  String get zip => 'ZIP';

  @override
  String processingProgress(int percent) {
    return '처리 중 ($percent%)...';
  }

  @override
  String savedXImages(int count) {
    return '✓ $count장의 이미지가 저장되었습니다!';
  }

  @override
  String zipError(String error) {
    return 'ZIP 오류: $error';
  }

  @override
  String get processedImages => '처리된 이미지';

  @override
  String get galleryEmpty => '이미지가 없습니다';

  @override
  String get noPastEdits => '기록이 없습니다';

  @override
  String get galleryEmptyDescription => '이미지를 처리하고 내보내면\n여기에 표시됩니다';

  @override
  String get startNewEdit => '새로 편집하기';

  @override
  String get unableToLoadHistory => '현재 기록을 불러올 수 없습니다';

  @override
  String get retry => '재시도';

  @override
  String get clearHistoryTitle => '기록을 삭제하시겠습니까?';

  @override
  String get clearHistoryMessage => '모든 과거 편집 기록이 삭제되며 복구할 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get clear => '삭제';

  @override
  String savedImages(int count) {
    return '$count장의 이미지가 저장되었습니다!';
  }

  @override
  String get subscription => '구독';

  @override
  String get upgradeSubtitle => '모든 기능 사용 & 광고 제거';

  @override
  String get proActive => 'Reducer Pro 활성화됨';

  @override
  String get supportThanks => '지원해 주셔서 감사합니다!';

  @override
  String get supportAndFeedback => '지원 및 피드백';

  @override
  String get rateOnPlayStore => 'Play 스토어 평점 남기기';

  @override
  String get shareReducer => 'Reducer 공유하기';

  @override
  String get contactSupport => '고객 지원 문의';

  @override
  String get profileImageUpdated => '프로필 이미지가 업데이트되었습니다!';

  @override
  String uploadFailed(String error) {
    return '업로드 실패: $error';
  }

  @override
  String get imagesStudio => '이미지 스튜디오';

  @override
  String get memberSince => '가입일';

  @override
  String get freeMember => '무료 회원';

  @override
  String get basicToolsEnabled => '기본 기능 활성화됨';

  @override
  String get goPro => 'Pro 가입하기';

  @override
  String get preferences => '환경 설정';

  @override
  String get logOut => '로그아웃';

  @override
  String get logOutConfirmation => '로그아웃하시겠습니까? 진행 사항은 클라우드에 동기화됩니다.';

  @override
  String get stay => '취소';

  @override
  String get accountStudio => '계정 스튜디오';

  @override
  String get startSession => '세션 시작';

  @override
  String get light => '라이트 모드';

  @override
  String get auto => '자동';

  @override
  String get dark => '다크 모드';

  @override
  String appVersionLabel(String version) {
    return 'Reducer Image Studio v$version';
  }

  @override
  String loginFailed(Object error) {
    return '로그인 실패: $error';
  }

  @override
  String googleSignInFailed(Object error) {
    return 'Google 로그인 실패: $error';
  }

  @override
  String get resetPassword => '비밀번호 재설정';

  @override
  String get resetPasswordDescription => '이메일 주소를 입력하시면 비밀번호 재설정 링크를 보내드립니다.';

  @override
  String get emailAddress => '이메일 주소';

  @override
  String get sendResetLink => '링크 보내기';

  @override
  String get passwordResetSent => '이메일이 발송되었습니다! 수신함을 확인해 주세요.';

  @override
  String get welcomeBack => '다시 만나서 반가워요';

  @override
  String get loginContinue => 'Reducer를 계속 사용하려면 로그인하세요';

  @override
  String get pleaseEnterEmail => '이메일을 입력하세요';

  @override
  String get pleaseEnterValidEmail => '유효한 이메일을 입력하세요';

  @override
  String get password => '비밀번호';

  @override
  String get pleaseEnterPassword => '비밀번호를 입력하세요';

  @override
  String get passwordLengthError => '비밀번호는 6자 이상이어야 합니다';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get login => '로그인';

  @override
  String get or => '또는';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get register => '회원가입';

  @override
  String get continueAsGuest => '게스트로 계속하기';

  @override
  String registrationFailed(Object error) {
    return '회원가입 실패: $error';
  }

  @override
  String get createAccount => '계정 만들기';

  @override
  String get joinAndStart => 'Reducer와 함께 창작을 시작하세요';

  @override
  String get fullName => '이름';

  @override
  String get pleaseEnterName => '이름을 입력하세요';

  @override
  String get nameLengthError => '이름은 2자 이상이어야 합니다';

  @override
  String get passwordComplexityError => '비밀번호에 숫자나 특수문자가 포함되어야 합니다';

  @override
  String get passwordLengthErrorRegister => '비밀번호는 8자 이상이어야 합니다';

  @override
  String get registerWithGoogle => 'Google로 가입하기';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get premiumMembership => 'PRO 멤버십';

  @override
  String get eliteMember => '엘리트 회원';

  @override
  String get fullAccessActive => 'Reducer Studio의 모든 기능을 사용할 수 있습니다.';

  @override
  String get currentPlan => '현재 플랜';

  @override
  String get statusLabel => '상태';

  @override
  String get startDate => '시작일';

  @override
  String get nextBilling => '다음 결제일';

  @override
  String get manageSubscription => '구독 관리';

  @override
  String get lifetime => '평생 소장';

  @override
  String get proAccess => 'PRO 액세스';

  @override
  String get unlockStudio => '모든 기능 잠금 해제';

  @override
  String get premiumSubtitle => '고성능 도구, AI 업스케일링,\n완벽한 광고 없는 환경을 경험하세요.';

  @override
  String get featureBulkStudio => '벌크 스튜디오 (일괄 크기 조정 및 내보내기)';

  @override
  String get featureAiTurbo => 'AI 터보 업스케일링 & 클린';

  @override
  String get featureZeroAds => '광고 없음. 완벽한 프라이버시.';

  @override
  String get featureDirectZip => '직접 ZIP 저장 & 4K 컬렉션';

  @override
  String get subscribeNow => '지금 구독하기';

  @override
  String get unlockPro => 'Pro 잠금 해제';

  @override
  String get cancelAnytime => '언제든 해지 가능. 안전한 결제.';

  @override
  String get restorePurchases => '구매 복원';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get noPlansAvailable => '현재 이용 가능한 플랜이 없습니다.';

  @override
  String get tryAgainLater => '나중에 다시 시도하거나 고객 지원에 문의하세요.';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get mostPopular => '인기';

  @override
  String get bestValue => '가성비 추천';

  @override
  String get selectPlan => '플랜 선택';

  @override
  String savePercent(String percent) {
    return '$percent% 절약';
  }

  @override
  String freeTrial(String days) {
    return '$days일 무료 체험';
  }

  @override
  String get clearHistoryContent => '과거 편집 내역이 삭제되며 복구할 수 없습니다.';

  @override
  String get historyLoadError => '현재 기록을 불러올 수 없습니다';

  @override
  String get imageActions => '이미지 작업';

  @override
  String get shareImage => '이미지 공유';

  @override
  String get savedToGallerySuccess => '갤러리에 저장되었습니다!';

  @override
  String get processedFileNotFound => '처리된 파일을 찾을 수 없습니다';

  @override
  String bulkCountLabel(Object count) {
    return '벌크 ($count장)';
  }

  @override
  String get resultSummary => '처리 결과 요약';

  @override
  String get output => '출력';

  @override
  String get saved => '저장됨';

  @override
  String get formatLabel => '형식';

  @override
  String get optimizationComplete => '최적화 완료! 🎉';

  @override
  String bulkOptimizationResult(
    int count,
    String original,
    String compressed,
    String reduction,
  ) {
    return '$count장의 이미지가 줄어들었습니다: $original → $compressed ($reduction% 감소)';
  }

  @override
  String imageTooLarge(Object size) {
    return '이미지 파일이 너무 큽니다 ($size MB).\n최대 용량은 50MB입니다.';
  }

  @override
  String get largeFileWarning => '대용량 파일입니다. 처리에 시간이 걸릴 수 있습니다.';

  @override
  String imageDimensionsTooLarge(Object height, Object width) {
    return '해상도가 너무 높습니다 (${width}x$height).\n최대 10000x10000 픽셀입니다.';
  }

  @override
  String get cannotDecodeImage => '이미지를 읽을 수 없습니다.\n파일이 손상되었거나 지원하지 않는 형식입니다.';

  @override
  String errorReadingImage(Object error) {
    return '읽기 오류: $error';
  }

  @override
  String get error => '오류';

  @override
  String get warning => '경고';

  @override
  String get ok => '확인';

  @override
  String get continueAnyway => '그래도 계속하기';

  @override
  String get bulkSessionDetails => '벌크 세션 상세';

  @override
  String xImagesProcessed(Object count) {
    return '$count장의 이미지가 처리되었습니다';
  }

  @override
  String get loadingImages => '이미지 불러오는 중...';

  @override
  String get noImagesFoundInSession => '세션에 이미지가 없습니다';

  @override
  String get signInRequired => '로그인 필요';

  @override
  String get signInRequiredDescription => 'Pro 기능을 사용하고 기록을 동기화하려면 로그인해 주세요.';

  @override
  String get signInNow => '지금 로그인';

  @override
  String get loginRequiredForPremium => '프리미엄 이용을 위해 로그인이 필요합니다';

  @override
  String get guestModePremiumMessage => '게스트 모드입니다. 구독 및 Pro 도구 사용을 위해 로그인하세요.';

  @override
  String subscribeWithPrice(String price, String period) {
    return '$price / $period로 구독';
  }

  @override
  String get startProAccess => 'PRO 액세스 시작';

  @override
  String trialPeriodText(String period) {
    return '$period 무료 체험 시작';
  }

  @override
  String get yearly => '연간';

  @override
  String get monthly => '월간';

  @override
  String get trial => '체험';

  @override
  String get year => '년';

  @override
  String get month => '월';

  @override
  String get yearSuffix => '/년';

  @override
  String get monthSuffix => '/월';

  @override
  String get freeLabel => '무료';

  @override
  String get permissionRequiredToAccessPhotos => '사진 접근 권한이 필요합니다';

  @override
  String unableToOpenGallery(Object error) {
    return '갤러리를 열 수 없습니다: $error';
  }

  @override
  String get storagePermissionRequiredToSave => '저장을 위해 저장소 권한이 필요합니다';

  @override
  String get failedToCleanMetadata => '메타데이터 제거 실패';

  @override
  String errorCleaningMetadata(Object error) {
    return '제거 오류: $error';
  }

  @override
  String get success => '성공!';

  @override
  String get exifSuccessMessage => '민감한 메타데이터가 제거되었습니다. 깨끗한 이미지가 갤러리에 저장되었습니다.';

  @override
  String get done => '완료';

  @override
  String freeTrialLeft(int count) {
    return '무료 체험 $count회 남음';
  }

  @override
  String get privacyFirst => '프라이버시 우선';

  @override
  String get privacyFirstDescription =>
      '공유하기 전 사진에서 GPS, 카메라 정보 등 메타데이터를 제거하세요.';

  @override
  String get cleaning => '정리 중...';

  @override
  String get cleanAndSave => '정리 및 저장';

  @override
  String get tapToSelectImage => '눌러서 이미지 선택';

  @override
  String get poweredByAi => 'AI 기반';

  @override
  String get about => '정보';

  @override
  String get privacyPolicy => '개인정보 처리방침';

  @override
  String get version => '버전';

  @override
  String get madeWithHeart => 'Tarur Infotech에서 ♥로 제작';

  @override
  String get lastUpdated => '최근 업데이트: 2026년 4월 5일';

  @override
  String get privacySection1Title => '1. 데이터 처리';

  @override
  String get privacySection1Content =>
      '모든 이미지 처리는 기기 내에서 로컬로 이루어집니다. 이미지를 서버에 업로드하지 않습니다.';

  @override
  String get privacySection2Title => '2. 정보 수집';

  @override
  String get privacySection2Content =>
      '익명의 사용 데이터만 수집합니다. 동의 없이 개인정보를 수집하지 않습니다.';

  @override
  String get privacySectionTitle3 => '3. 제3자 서비스';

  @override
  String get privacySectionContent3 =>
      '광고에 Google AdMob, 구독 관리에 RevenueCat을 사용합니다.';

  @override
  String get privacySectionTitle4 => '4. 기기 권한';

  @override
  String get privacySectionContent4 => '편집 및 저장을 위해 사진/저장소 접근 권한만 요청합니다.';

  @override
  String get privacySectionTitle5 => '5. 문의하기';

  @override
  String get privacySectionContent5 =>
      '문의 사항은 tarurinfotech@gmail.com으로 연락주세요.';

  @override
  String shareAppText(String url) {
    return 'Reducer를 사용해 보세요! 최고의 이미지 압축 및 처리 도구입니다. 다운로드: $url';
  }

  @override
  String get signInBenefit =>
      'Sign in to unlock cross-device sync,\nPro features, and your history.';

  @override
  String get fullAccessUnlocked => 'Full access unlocked';

  @override
  String get logoutConfirm =>
      'Ready to leave? Your progress is safely synced to the cloud.';

  @override
  String get email => 'Email';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to permanently delete your account? This action cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully.';

  @override
  String get deleteAccountReauthNeeded =>
      'Deletion failed. For security, you may need to log out and log back in before deleting your account.';

  @override
  String get account => 'Account';

  @override
  String get buy => 'BUY';

  @override
  String get popular => 'Popular';

  @override
  String get successPurchase => 'Welcome to Premium! 🎉';

  @override
  String get successRestore => 'Restored Successfully!';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get noProcessedImageYet => 'No processed image yet';

  @override
  String get processImageFirstHint =>
      'Go to the Settings tab and tap \"Process Image\".';

  @override
  String get beforeOriginal => 'Before (Original)';

  @override
  String get afterProcessed => 'After (Processed)';

  @override
  String get comparePreviewLabel => 'Processed image preview';

  @override
  String get holdImageToCompare => 'Hold image to compare';

  @override
  String get sizeReducedLabel => 'Size Reduced';

  @override
  String get noName => 'No Name';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get undo => 'Undo';
}
