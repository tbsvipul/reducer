import '../../domain/models/app_language.dart';

class AppLanguages {
  static const List<AppLanguage> all = [
    AppLanguage(
      name: 'United States',
      sub: 'English',
      code: 'en',
      flag: 'assets/flags/us.png',
    ),
    AppLanguage(
      name: 'China',
      sub: 'Chinese (Simplified)',
      code: 'zh',
      flag: 'assets/flags/cn.png',
    ),
    AppLanguage(
      name: 'India',
      sub: 'Hindi',
      code: 'hi',
      flag: 'assets/flags/in.png',
    ),
    AppLanguage(
      name: 'Spain',
      sub: 'Spanish',
      code: 'es',
      flag: 'assets/flags/es.png',
    ),
    AppLanguage(
      name: 'Saudi Arabia',
      sub: 'Arabic',
      code: 'ar',
      flag: 'assets/flags/sa.png',
    ),
    AppLanguage(
      name: 'France',
      sub: 'French',
      code: 'fr',
      flag: 'assets/flags/fr.png',
    ),
    AppLanguage(
      name: 'Brazil',
      sub: 'Portuguese',
      code: 'pt',
      flag: 'assets/flags/br.png',
    ),
    AppLanguage(
      name: 'Russia',
      sub: 'Russian',
      code: 'ru',
      flag: 'assets/flags/ru.png',
    ),
    AppLanguage(
      name: 'Germany',
      sub: 'German',
      code: 'de',
      flag: 'assets/flags/de.png',
    ),
    AppLanguage(
      name: 'Japan',
      sub: 'Japanese',
      code: 'ja',
      flag: 'assets/flags/jp.png',
    ),
    AppLanguage(
      name: 'South Korea',
      sub: 'Korean',
      code: 'ko',
      flag: 'assets/flags/kr.png',
    ),
    AppLanguage(
      name: 'Turkey',
      sub: 'Turkish',
      code: 'tr',
      flag: 'assets/flags/tr.png',
    ),
    AppLanguage(
      name: 'Vietnam',
      sub: 'Vietnamese',
      code: 'vi',
      flag: 'assets/flags/vn.png',
    ),
    AppLanguage(
      name: 'Indonesia',
      sub: 'Indonesian',
      code: 'id',
      flag: 'assets/flags/id.png',
    ),
    AppLanguage(
      name: 'Poland',
      sub: 'Polish',
      code: 'pl',
      flag: 'assets/flags/pl.png',
    ),
    AppLanguage(
      name: 'Estonia',
      sub: 'Estonian',
      code: 'et',
      flag: 'assets/flags/ee.png',
    ),
  ];

  static AppLanguage? fromCode(String code) {
    try {
      return all.firstWhere((lang) => lang.code == code);
    } catch (_) {
      return null;
    }
  }
}
