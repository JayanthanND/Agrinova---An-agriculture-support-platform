import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _currentLocale = Locale('en');
  Map<String, String> _localizedStrings = {};

  Locale get locale => _currentLocale;

  Future<void> loadLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('language') ?? 'en';
    _currentLocale = Locale(languageCode);
    await _loadTranslations(languageCode);
    notifyListeners(); // 🔹 Notify UI to rebuild
  }

  Future<void> setLanguage(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    _currentLocale = Locale(languageCode);
    await _loadTranslations(languageCode);
    notifyListeners(); // 🔹 Notify UI to rebuild
  }

  Future<void> _loadTranslations(String languageCode) async {
    try {
      String jsonString =
          await rootBundle.loadString('lib/src/Language/$languageCode.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings =
          jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      print('Error loading translations: $e');
    }
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
