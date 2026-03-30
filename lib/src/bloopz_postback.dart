import 'package:http/http.dart' as http;
import 'dart:convert';

class BloopzPostback {
  static Uri buildCpiUri({String baseUrl = 'https://www.bloopz.com'}) =>
      Uri.parse(baseUrl).replace(path: '/api/postback/cpi');

  /// Sends the CPI postback to Bloopz.
  ///
  /// Docs recommend doing this from your server when possible so the URL/params
  /// are not exposed to the client. This helper is provided for convenience.
  static Future<http.Response> sendCpi({
    required String utmMedium,
    required String key,
    String utmSource = 'bloopz',
    String baseUrl = 'https://www.bloopz.com',
    http.Client? client,
  }) async {
    final c = client ?? http.Client();
    try {
      final uri = buildCpiUri(baseUrl: baseUrl);
      return await c.post(
        uri,
        headers: const <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'utm_source': utmSource,
          'utm_medium': utmMedium,
          'key': key,
        }),
      );
    } finally {
      if (client == null) c.close();
    }
  }
}

