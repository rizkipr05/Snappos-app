import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage.dart';

class Api {
  /// BASE API (router)
  static const String baseUrl =
      "http://localhost:8080/snappos_api/public/index.php";

  /// BASE PUBLIC (untuk file static: images)
  static String get publicBaseUrl => baseUrl
      .replaceAll("/index.php", "")
      .replaceAll(RegExp(r"/+$"), "");

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

  /// Multipart upload (Create/Update) with optional file.
  /// - method: "POST" (create) or "PUT" (update). For PHP micro-router,
  ///   biasanya update pakai POST + _method=PUT (ini kita support).
  static Future<dynamic> postMultipart(
    String path,
    Map<String, dynamic> fields, {
    String? token,
    String? filePath,
    String fileField = "image",
    String method = "POST", // "POST" | "PUT"
  }) async {
    token ??= await Storage.getToken();

    final uri = Uri.parse("$baseUrl$path");

    // Kita tetap pakai POST untuk kompatibilitas PHP + _method override
    final req = http.MultipartRequest("POST", uri);

    req.headers.addAll({
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    });

    // Convert dynamic -> String (wajib untuk multipart fields)
    fields.forEach((k, v) {
      if (v == null) return;
      req.fields[k] = v.toString();
    });

    // Method override untuk update
    final m = method.toUpperCase().trim();
    if (m != "POST") {
      req.fields["_method"] = m; // backend harus baca ini (atau router)
    }

    // Attach file kalau ada
    if (filePath != null && filePath.trim().isNotEmpty) {
      req.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    final body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (res.statusCode >= 400) throw body["message"] ?? "Request failed";
    return body;
  }
}
