import 'package:shared_preferences/shared_preferences.dart';

/// 本地配置持久化服务
class StorageService {
  static const _keyBaseUrl = 'api_base_url';
  static const _keyApiKey = 'api_key';
  static const _keyModel = 'api_model';
  static const _keyThemeMode = 'theme_mode';

  // 默认值
  static const String defaultBaseUrl = 'https://api.deepseek.com';
  static const String defaultModel = 'deepseek-v4-flash';

  static late SharedPreferences _prefs;

  /// 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ---- API Base URL ----
  static String get baseUrl =>
      _prefs.getString(_keyBaseUrl) ?? defaultBaseUrl;
  static set baseUrl(String value) => _prefs.setString(_keyBaseUrl, value);

  // ---- API Key ----
  static String? get apiKey => _prefs.getString(_keyApiKey);
  static set apiKey(String? value) {
    if (value != null && value.isNotEmpty) {
      _prefs.setString(_keyApiKey, value);
    } else {
      _prefs.remove(_keyApiKey);
    }
  }

  /// 是否已配置 API Key
  static bool get hasApiKey =>
      _prefs.containsKey(_keyApiKey) &&
      (_prefs.getString(_keyApiKey)?.isNotEmpty ?? false);

  // ---- Model ----
  static String get model =>
      _prefs.getString(_keyModel) ?? defaultModel;
  static set model(String value) => _prefs.setString(_keyModel, value);

  // ---- Theme Mode ----
  /// 'light' or 'dark' (default: 'light')
  static String get themeMode =>
      _prefs.getString(_keyThemeMode) ?? 'light';
  static set themeMode(String value) => _prefs.setString(_keyThemeMode, value);
}
