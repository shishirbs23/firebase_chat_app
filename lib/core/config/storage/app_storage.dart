import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _keyLoggedIn = '_keyLoggedIn';
  static const _keyAuthToken = '_keyAuthToken';
  static const _keyDeviceId = '_keyDeviceId';

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String> getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken) ?? "";
  }

  void setAuthToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyAuthToken, token);
  }

  Future<void> clearUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyDeviceId);
    return;
  }

  Future<String> getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId) ?? "";
  }

  void setDeviceId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_keyDeviceId, id);
  }
}
