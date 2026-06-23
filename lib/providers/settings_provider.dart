import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// 设置管理
class SettingsProvider extends ChangeNotifier {
  String _baseUrl = StorageService.baseUrl;
  String _apiKey = StorageService.apiKey ?? '';
  String _model = StorageService.model;

  // --- Getters ---
  String get baseUrl => _baseUrl;
  String get apiKey => _apiKey;
  String get model => _model;
  bool get hasApiKey => _apiKey.isNotEmpty;

  // --- 加载配置 ---
  void load() {
    _baseUrl = StorageService.baseUrl;
    _apiKey = StorageService.apiKey ?? '';
    _model = StorageService.model;
    notifyListeners();
  }

  // --- 保存 Base URL ---
  void setBaseUrl(String value) {
    _baseUrl = value.trim();
    StorageService.baseUrl = _baseUrl;
    notifyListeners();
  }

  // --- 保存 API Key ---
  void setApiKey(String value) {
    _apiKey = value.trim();
    StorageService.apiKey = _apiKey;
    notifyListeners();
  }

  // --- 保存 Model ---
  void setModel(String value) {
    _model = value.trim();
    StorageService.model = _model;
    notifyListeners();
  }
}
