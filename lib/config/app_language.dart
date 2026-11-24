import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appLanguageProvider = ChangeNotifierProvider<AppLanguageController>(
  (ref) => AppLanguageController()..load(),
);

class AppLanguageController extends ChangeNotifier {
  static const _preferenceKey = 'app_language';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isHindi => _locale.languageCode == 'hi';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguage = preferences.getString(_preferenceKey) ?? 'en';
    _locale = Locale(savedLanguage);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_preferenceKey, languageCode);
  }
}

String appText(BuildContext context, String english, String hindi) {
  return Localizations.localeOf(context).languageCode == 'hi' ? hindi : english;
}
