import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage.dart';

class Api {
  static const String baseUrl =
      "http://10.109.104.77:8080/snappos_api/public/index.php";

  static Future<dynamic> get(String path, {String? token}) async {
    token ??= await Storage.getToken();

    final res = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
    );

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) throw body["message"] ?? "Request failed";
    return body;
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    token ??= await Storage.getToken();

    final res = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) throw body["message"] ?? "Request failed";
    return body;
  }
  static Future<dynamic> put(
    String path,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    token ??= await Storage.getToken();

    final res = await http.put(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) throw body["message"] ?? "Request failed";
    return body;
  }

  static Future<dynamic> delete(String path, {String? token}) async {
    token ??= await Storage.getToken();

    final res = await http.delete(
      Uri.parse("$baseUrl$path"),
      headers: {
        "Accept": "application/json",
        if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
      },
    );

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) throw body["message"] ?? "Request failed";
    return body;
  }
}
