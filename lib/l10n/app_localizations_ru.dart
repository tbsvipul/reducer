// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get continueLabel => 'Продолжить';

  @override
  String get searchLanguage => 'Поиск языка...';

  @override
  String get welcomeToReducer => 'Добро пожаловать в Reducer';

  @override
  String get setupLanguageSubtitle =>
      'Выберите предпочтительный язык, чтобы начать работу с лучшим сервисом по оптимизации изображений.';

  @override
  String get appTitle => 'REDUCER';

  @override
  String get homeTitle => 'Студия';

  @override
  String get bulkStudio => 'Пакетная студия';

  @override
  String get history => 'История';

  @override
  String get profile => 'Профиль';

  @override
  String get singleEditor => 'Одиночный редактор';

  @override
  String get startBatchProcessing => 'Начать пакетную обработку';

  @override
  String get selectImages => 'Выбрать изображения';

  @override
  String get saveToGallery => 'Сохранить в галерею';

  @override
  String get share => 'Поделиться';

  @override
  String get processing => 'Обработка...';

  @override
  String get settings => 'Настройки';

  @override
  String get premium => 'Премиум';

  @override
  String get compressionSuccess => '✓ Сохранено в галерею!';

  @override
  String get freeLimitMessage =>
      'Бесплатно: лимит 50 изображений. Обновитесь для большего.';

  @override
  String get quickStart => 'Быстрый старт';

  @override
  String get howItWorks => 'Как это работает';

  @override
  String get optimizeImage => 'Оптимизировать фото';

  @override
  String get optimizeSubtitle => 'Уменьшите размер без потери качества';

  @override
  String get convert => 'Конвертировать';

  @override
  String get convertSubtitle => 'PNG, WebP и др.';

  @override
  String get historySubtitle => 'Недавние правки';

  @override
  String get advancedTools => 'Продвинутые инструменты';

  @override
  String get proBadge => 'PRO';

  @override
  String get bulkProcessing => 'Пакетная обработка';

  @override
  String get bulkSubtitle => 'Обработка до 50 фото одновременно';

  @override
  String get exifEraser => 'Очистка EXIF';

  @override
  String get exifSubtitle => 'Удаление метаданных для приватности';

  @override
  String get viewHistory => 'История правок';

  @override
  String get viewHistorySubtitle => 'Просмотр и экспорт прошлых работ';

  @override
  String get unlockReducerPro => 'Разблокировать Reducer Pro';

  @override
  String get unlockAllProFeatures => 'Разблокировать все Pro функции';

  @override
  String get proDescription =>
      'Пакетная обработка и отсутствие рекламы доступны только для Pro участников. Присоединяйтесь сегодня!';

  @override
  String get promoSubtitle =>
      'Пакетная обработка, без рекламы, экспорт высокого качества и др.';

  @override
  String get upgradeToPro => 'Перейти на Pro';

  @override
  String get upgradeNow => 'Обновить сейчас';

  @override
  String get maybeLater => 'Возможно позже';

  @override
  String get compress => 'Сжать';

  @override
  String get resize => 'Размер';

  @override
  String get format => 'Формат';

  @override
  String get export => 'Экспорт';

  @override
  String get processImage => 'Обработать фото';

  @override
  String get showBefore => 'До';

  @override
  String get showAfter => 'После';

  @override
  String get originalSize => 'Оригинал';

  @override
  String get compressed => 'Сжато';

  @override
  String get dimensions => 'Размеры';

  @override
  String get readyToExport => 'Готово к экспорту!';

  @override
  String get applyChangesMessage =>
      'Примените изменения и нажмите «Обработать фото» для результата.';

  @override
  String get itemRemoved => 'Элемент удален из истории';

  @override
  String get selectOutputFormat => 'Выберите формат';

  @override
  String get formatDescription => 'Выберите тип файла, который вам подходит';

  @override
  String get targetFileSize => 'Целевой размер файла';

  @override
  String get imageQuality => 'Качество изображения';

  @override
  String get smallerFile => 'Меньше размер';

  @override
  String get higherQuality => 'Выше качество';

  @override
  String get sizeHint => 'напр. 2.5';

  @override
  String get customDimensions => 'Свой размер';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Высота';

  @override
  String get lockAspectRatio => 'Сохранять пропорции';

  @override
  String get aspectRatioMaintained => 'Пропорции сохранены';

  @override
  String get transform => 'Трансформация';

  @override
  String get flipHorizontal => 'Отразить по горизонтали';

  @override
  String get pickImageToStart => 'Выберите фото для начала';

  @override
  String get pickImageSubtitle => 'Выберите из галереи или сделайте фото';

  @override
  String get gallery => 'Галерея';

  @override
  String get camera => 'Камера';

  @override
  String failedToSave(String error) {
    return 'Ошибка сохранения: $error';
  }

  @override
  String failedToShare(String error) {
    return 'Ошибка отправки: $error';
  }

  @override
  String get processingDot => 'Обработка...';

  @override
  String get shareWithReducer => 'Обработано в Reducer';

  @override
  String get batchOptimizationComplete => 'ПАКЕТНАЯ ОПТИМИЗАЦИЯ ЗАВЕРШЕНА';

  @override
  String get smaller => 'Меньше';

  @override
  String get freeUserLimit => 'Бесплатно: 50 изображений. Обновитесь до Pro.';

  @override
  String get batchProcessing => 'Пакетная обработка';

  @override
  String get batchDescription => 'Оптимизируйте сотни фото за раз';

  @override
  String get selectMultipleImages => 'Выбрать несколько фото';

  @override
  String get bulkSettingsNote => 'Настройки применятся ко ВСЕМ выбранным фото.';

  @override
  String get bulkResizeNote => 'Для пакетов рекомендуется масштабирование в %.';

  @override
  String get bulkFormatNote => 'Все фото будут сохранены в выбранном формате.';

  @override
  String get autoQualityActive =>
      'Авто-качество: ползунок игнорируется для достижения нужного размера.';

  @override
  String get scalePercentRecommended => 'Масштаб % (Рекомендуется)';

  @override
  String get chooseOutputFormat => 'Выбрать формат';

  @override
  String get bestForPhotos => 'Лучше для фото';

  @override
  String get bestForGraphics => 'Лучше для графики';

  @override
  String get modernAndSmall => 'Современный и компактный';

  @override
  String get uncompressed => 'Без сжатия';

  @override
  String get original => 'Оригинал';

  @override
  String get fixedDimensionsExpert => 'Точный размер (Эксперт)';

  @override
  String get totalOriginal => 'Общий оригинал';

  @override
  String get totalCompressed => 'Общий сжатый';

  @override
  String get spaceSaved => 'Место сэкономлено';

  @override
  String get saveAll => 'Сохранить все';

  @override
  String get zip => 'ZIP';

  @override
  String processingProgress(int percent) {
    return 'Обработка ($percent%)...';
  }

  @override
  String savedXImages(int count) {
    return '✓ Сохранено $count фото!';
  }

  @override
  String zipError(String error) {
    return 'Ошибка ZIP: $error';
  }

  @override
  String get processedImages => 'Обработанные фото';

  @override
  String get galleryEmpty => 'Здесь пока пусто';

  @override
  String get noPastEdits => 'Нет правок';

  @override
  String get galleryEmptyDescription =>
      'Обработайте фото,\nчтобы увидеть их здесь';

  @override
  String get startNewEdit => 'Начать новую правку';

  @override
  String get unableToLoadHistory => 'Не удалось загрузить историю';

  @override
  String get retry => 'Повторить';

  @override
  String get clearHistoryTitle => 'Очистить историю?';

  @override
  String get clearHistoryMessage =>
      'Все прошлые правки будут удалены. Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get clear => 'Очистить';

  @override
  String savedImages(int count) {
    return 'Сохранено $count фото!';
  }

  @override
  String get subscription => 'Подписка';

  @override
  String get upgradeSubtitle => 'Откройте все функции и уберите рекламу';

  @override
  String get proActive => 'Reducer Pro активирован';

  @override
  String get supportThanks => 'Спасибо за поддержку!';

  @override
  String get supportAndFeedback => 'Поддержка и отзывы';

  @override
  String get rateOnPlayStore => 'Оценить в Play Store';

  @override
  String get shareReducer => 'Поделиться Reducer';

  @override
  String get contactSupport => 'Написать в поддержку';

  @override
  String get profileImageUpdated => 'Аватарка обновлена!';

  @override
  String uploadFailed(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get imagesStudio => 'Студия изображений';

  @override
  String get memberSince => 'В приложении с';

  @override
  String get freeMember => 'Бесплатный аккаунт';

  @override
  String get basicToolsEnabled => 'Базовые инструменты доступны';

  @override
  String get goPro => 'Стать Pro';

  @override
  String get preferences => 'Настройки';

  @override
  String get logOut => 'Выйти';

  @override
  String get logOutConfirmation =>
      'Хотите выйти? Прогресс синхронизирован с облаком.';

  @override
  String get stay => 'Остаться';

  @override
  String get accountStudio => 'Аккаунт Студии';

  @override
  String get startSession => 'Начать сессию';

  @override
  String get light => 'Светлая';

  @override
  String get auto => 'Авто';

  @override
  String get dark => 'Темная';

  @override
  String appVersionLabel(String version) {
    return 'Reducer Image Studio v$version';
  }

  @override
  String loginFailed(Object error) {
    return 'Ошибка входа: $error';
  }

  @override
  String googleSignInFailed(Object error) {
    return 'Ошибка входа через Google: $error';
  }

  @override
  String get resetPassword => 'Сброс пароля';

  @override
  String get resetPasswordDescription =>
      'Введите email, и мы отправим ссылку для сброса пароля.';

  @override
  String get emailAddress => 'Email адрес';

  @override
  String get sendResetLink => 'Отправить ссылку';

  @override
  String get passwordResetSent =>
      'Письмо отправлено! Проверьте папку «Входящие».';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get loginContinue => 'Войдите, чтобы продолжить работу в Reducer';

  @override
  String get pleaseEnterEmail => 'Введите email';

  @override
  String get pleaseEnterValidEmail => 'Введите корректный email';

  @override
  String get password => 'Пароль';

  @override
  String get pleaseEnterPassword => 'Введите пароль';

  @override
  String get passwordLengthError => 'Пароль должен быть от 6 символов';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get login => 'Войти';

  @override
  String get or => 'ИЛИ';

  @override
  String get continueWithGoogle => 'Продолжить через Google';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get register => 'Регистрация';

  @override
  String get continueAsGuest => 'Войти как гость';

  @override
  String registrationFailed(Object error) {
    return 'Ошибка регистрации: $error';
  }

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get joinAndStart => 'Присоединяйтесь к Reducer и творите';

  @override
  String get fullName => 'Полное имя';

  @override
  String get pleaseEnterName => 'Введите имя';

  @override
  String get nameLengthError => 'Имя должно быть от 2 символов';

  @override
  String get passwordComplexityError => 'Должна быть цифра или спецсимвол';

  @override
  String get passwordLengthErrorRegister => 'Пароль должен быть от 8 символов';

  @override
  String get registerWithGoogle => 'Регистрация через Google';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get premiumMembership => 'PRO ПОДПИСКА';

  @override
  String get eliteMember => 'Элитный участник';

  @override
  String get fullAccessActive => 'Полный доступ к Reducer Studio активен.';

  @override
  String get currentPlan => 'Текущий план';

  @override
  String get statusLabel => 'Статус';

  @override
  String get startDate => 'Дата начала';

  @override
  String get nextBilling => 'След. оплата';

  @override
  String get manageSubscription => 'Управление подпиской';

  @override
  String get lifetime => 'Пожизненно';

  @override
  String get proAccess => 'ДОСТУП PRO';

  @override
  String get unlockStudio => 'Открыть всю студию';

  @override
  String get premiumSubtitle =>
      'Мощные инструменты, AI-улучшение фото\nи полное отсутствие рекламы.';

  @override
  String get featureBulkStudio => 'Пакетная студия (Масштаб и Экспорт)';

  @override
  String get featureAiTurbo => 'AI Turbo Scaling & Clean';

  @override
  String get featureZeroAds => 'Без рекламы. Полная приватность.';

  @override
  String get featureDirectZip => 'Прямой ZIP и 4K коллекции';

  @override
  String get subscribeNow => 'Подписаться сейчас';

  @override
  String get unlockPro => 'Открыть Pro';

  @override
  String get cancelAnytime => 'Отмена в любое время. Безопасная оплата.';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get noPlansAvailable => 'Планы пока недоступны.';

  @override
  String get tryAgainLater => 'Попробуйте позже или напишите нам.';

  @override
  String get errorOccurred => 'Ой! Что-то пошло не так';

  @override
  String get mostPopular => 'ПОПУЛЯРНО';

  @override
  String get bestValue => 'ВЫГОДНО';

  @override
  String get selectPlan => 'ВЫБРАТЬ ПЛАН';

  @override
  String savePercent(String percent) {
    return 'ЭКОНОМИЯ $percent%';
  }

  @override
  String freeTrial(String days) {
    return '$days дн. бесплатно';
  }

  @override
  String get clearHistoryContent =>
      'Все прошлые правки будут удалены. Это нельзя отменить.';

  @override
  String get historyLoadError => 'Ошибка загрузки истории';

  @override
  String get imageActions => 'Действия';

  @override
  String get shareImage => 'Поделиться';

  @override
  String get savedToGallerySuccess => 'Сохранено в галерею!';

  @override
  String get processedFileNotFound => 'Файл не найден';

  @override
  String bulkCountLabel(Object count) {
    return 'ПАКЕТ ($count)';
  }

  @override
  String get resultSummary => 'ИТОГИ';

  @override
  String get output => 'РЕЗУЛЬТАТ';

  @override
  String get saved => 'СОХРАНЕНО';

  @override
  String get formatLabel => 'ФОРМАТ';

  @override
  String get optimizationComplete => 'Готово! 🎉';

  @override
  String bulkOptimizationResult(
    int count,
    String original,
    String compressed,
    String reduction,
  ) {
    return 'Сжато $count фото: $original → $compressed (меньше на $reduction%)';
  }

  @override
  String imageTooLarge(Object size) {
    return 'Файл слишком большой ($size МБ).\nМаксимум 50 МБ.';
  }

  @override
  String get largeFileWarning => 'Большой файл. Обработка может занять время.';

  @override
  String imageDimensionsTooLarge(Object height, Object width) {
    return 'Разрешение слишком большое (${width}x$height).\nМаксимум 10000x10000 пикселей.';
  }

  @override
  String get cannotDecodeImage =>
      'Ошибка чтения фото.\nФайл поврежден или неверный формат.';

  @override
  String errorReadingImage(Object error) {
    return 'Ошибка чтения: $error';
  }

  @override
  String get error => 'Ошибка';

  @override
  String get warning => 'Предупреждение';

  @override
  String get ok => 'ОК';

  @override
  String get continueAnyway => 'Все равно продолжить';

  @override
  String get bulkSessionDetails => 'Детали пакетной сессии';

  @override
  String xImagesProcessed(Object count) {
    return 'Обработано $count фото';
  }

  @override
  String get loadingImages => 'Загрузка фото...';

  @override
  String get noImagesFoundInSession => 'Фото не найдены';

  @override
  String get signInRequired => 'Нужен вход';

  @override
  String get signInRequiredDescription =>
      'Войдите, чтобы использовать Pro и синхронизировать работы.';

  @override
  String get signInNow => 'Войти сейчас';

  @override
  String get loginRequiredForPremium => 'Нужен вход для Premium';

  @override
  String get guestModePremiumMessage =>
      'Гостевой режим. Войдите для Premium и Pro инструментов.';

  @override
  String subscribeWithPrice(String price, String period) {
    return 'Подписка $price / $period';
  }

  @override
  String get startProAccess => 'НАЧАТЬ PRO ДОСТУП';

  @override
  String trialPeriodText(String period) {
    return 'Начните с $period бесплатно';
  }

  @override
  String get yearly => 'ГОДОВАЯ';

  @override
  String get monthly => 'МЕСЯЧНАЯ';

  @override
  String get trial => 'ПРОБНАЯ';

  @override
  String get year => 'год';

  @override
  String get month => 'месяц';

  @override
  String get yearSuffix => '/год';

  @override
  String get monthSuffix => '/мес';

  @override
  String get freeLabel => 'БЕСПЛАТНО';

  @override
  String get permissionRequiredToAccessPhotos => 'Нужен доступ к фото';

  @override
  String unableToOpenGallery(Object error) {
    return 'Ошибка доступа к галерее: $error';
  }

  @override
  String get storagePermissionRequiredToSave =>
      'Нужен доступ к памяти для сохранения';

  @override
  String get failedToCleanMetadata => 'Ошибка очистки метаданных';

  @override
  String errorCleaningMetadata(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String get success => 'Успешно!';

  @override
  String get exifSuccessMessage => 'Метаданные удалены. Чистое фото в галерее.';

  @override
  String get done => 'Готово';

  @override
  String freeTrialLeft(int count) {
    return 'Осталось $count пробных раз';
  }

  @override
  String get privacyFirst => 'Приватность прежде всего';

  @override
  String get privacyFirstDescription =>
      'Удаляйте GPS, инфо о камере и др. перед отправкой.';

  @override
  String get cleaning => 'Очистка...';

  @override
  String get cleanAndSave => 'Очистить и сохранить';

  @override
  String get tapToSelectImage => 'Нажмите, чтобы выбрать фото';

  @override
  String get poweredByAi => 'НА БАЗЕ ИИ';

  @override
  String get about => 'О приложении';

  @override
  String get privacyPolicy => 'Приватность';

  @override
  String get version => 'Версия';

  @override
  String get madeWithHeart => 'Сделано с ♥ в Tarur Infotech';

  @override
  String get lastUpdated => 'Обновлено: 05 апреля 2026';

  @override
  String get privacySection1Title => '1. Обработка данных';

  @override
  String get privacySection1Content =>
      'Вся обработка происходит локально. Мы не загружаем ваши фото.';

  @override
  String get privacySection2Title => '2. Сбор информации';

  @override
  String get privacySection2Content =>
      'Только анонимные данные об ошибках. Никаких личных данных без согласия.';

  @override
  String get privacySectionTitle3 => '3. Сторонние сервисы';

  @override
  String get privacySectionContent3 =>
      'AdMob для рекламы, RevenueCat для подписки.';

  @override
  String get privacySectionTitle4 => '4. Разрешения';

  @override
  String get privacySectionContent4 =>
      'Доступ только к фото для редактирования.';

  @override
  String get privacySectionTitle5 => '5. Контакты';

  @override
  String get privacySectionContent5 => 'Вопросы? tarurinfotech@gmail.com.';

  @override
  String shareAppText(String url) {
    return 'Попробуй Reducer — лучший инструмент для сжатия фото! Скачай здесь: $url';
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
