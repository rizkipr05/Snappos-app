import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  // Android emulator: 10.0.2.2
  // Chrome / Web: localhost
  static const String baseUrl =
      "http://192.168.11.205/snappos_api/public/index.php";

  static Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final uri = Uri.parse("$baseUrl$path");

    final res = await http.get(
      uri,
      headers: {
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    final data = json.decode(res.body.isEmpty ? "{}" : res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Request failed");
    }
    return data;
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse("$baseUrl$path");

    final res = await http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: json.encode(body ?? {}),
    );

    final data = json.decode(res.body.isEmpty ? "{}" : res.body);
    if (res.statusCode >= 400) {
      throw Exception(data["message"] ?? "Request failed");
    }
    return data;
  }
}
