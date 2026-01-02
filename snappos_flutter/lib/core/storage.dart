import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _kToken = 'auth_token';

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kToken);
  }

  static Future<void> setToken(String token) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
  }

  static Future<String?> getRole() async {
    final p = await SharedPreferences.getInstance();
    return p.getString("role");
  }

  static Future<void> setRole(String role) async {
    final p = await SharedPreferences.getInstance();
    await p.setString("role", role);
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove("role");
  }
}
