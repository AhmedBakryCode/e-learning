import 'dart:convert';
import 'package:e_learning/features/auth/data/models/app_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';

  final SharedPreferences _prefs;

  SessionManager(this._prefs);

  Future<void> saveSession(String token, AppUserModel user) async {
    await _prefs.setString(_keyToken, token);
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  String? getToken() => _prefs.getString(_keyToken);

  AppUserModel? getUser() {
    final userJson = _prefs.getString(_keyUser);
    if (userJson == null) return null;
    try {
      return AppUserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  bool get hasSession => getToken() != null;
}
