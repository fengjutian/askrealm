import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 本地配置持久化服务
class StorageService {
  static const _keyBaseUrl = 'api_base_url';
  static const _keyApiKey = 'api_key';
  static const _keyModel = 'api_model';
  static const _keyThemeMode = 'theme_mode';
  static const _keyFavCombos = 'favorite_combos';

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

  // ---- 多人模式收藏组合 ----
  /// 收藏的组合列表，每个组合是一组角色 id
  static List<List<String>> get favoriteCombos {
    final raw = _prefs.getString(_keyFavCombos);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => (e as List).cast<String>()).toList();
  }

  /// 添加收藏组合
  static Future<bool> addFavoriteCombo(List<String> charIds) async {
    final combos = favoriteCombos;
    // 避免重复（顺序敏感）
    final key = charIds.join(',');
    if (combos.any((c) => c.join(',') == key)) return false;
    combos.add(charIds);
    await _prefs.setString(_keyFavCombos, jsonEncode(combos));
    return true;
  }

  /// 移除收藏组合
  static Future<void> removeFavoriteCombo(List<String> charIds) async {
    final combos = favoriteCombos;
    final key = charIds.join(',');
    combos.removeWhere((c) => c.join(',') == key);
    await _prefs.setString(_keyFavCombos, jsonEncode(combos));
  }
}
