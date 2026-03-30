import 'package:http/http.dart' as http;

class BloopzPostback {
  static Uri buildCpiUri({
    required String utmMedium,
    String utmSource = 'bloopz',
    String baseUrl = 'https://www.bloopz.com',
  }) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      path: '/api/postback/cpi',
      queryParameters: <String, String>{
        'utm_source': utmSource,
        'utm_medium': utmMedium,
      },
    );
  }

  /// Sends the CPI postback to Bloopz.
  ///
  /// Docs recommend doing this from your server when possible so the URL/params
  /// are not exposed to the client. This helper is provided for convenience.
  static Future<http.Response> sendCpi({
    required String utmMedium,
    String utmSource = 'bloopz',
    String baseUrl = 'https://www.bloopz.com',
    http.Client? client,
  }) async {
    final c = client ?? http.Client();
    try {
      final uri = buildCpiUri(utmMedium: utmMedium, utmSource: utmSource, baseUrl: baseUrl);
      return await c.get(uri);
    } finally {
      if (client == null) c.close();
    }
  }
}

