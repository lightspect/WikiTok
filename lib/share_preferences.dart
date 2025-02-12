import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static final SharedPreferencesManager _instance =
      SharedPreferencesManager._internal();
  SharedPreferencesAsync? _preferences;

  factory SharedPreferencesManager() {
    return _instance;
  }

  SharedPreferencesManager._internal();

  Future<void> init() async {
    _preferences = SharedPreferencesAsync();
  }

  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return await _preferences?.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return await _preferences?.getInt(key);
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clear() async {
    await _preferences?.clear();
  }
}
