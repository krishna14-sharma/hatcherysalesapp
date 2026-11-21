import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkHelper {
  NetworkHelper(this.url);

  final Uri url;

  /// GETs [url] and decodes the JSON body.
  ///
  /// Throws on timeout or a non-200 status so callers never mistake a failed
  /// request for a successful one (previously this silently returned null,
  /// which is how failed saves were still reported as "Saved").
  Future getData({Duration timeout = const Duration(seconds: 30)}) async {
    final http.Response response = await http.get(url).timeout(timeout);

    if (response.statusCode == 200) {
      // Most endpoints reply with JSON. Insert endpoints (InsertTrData,
      // InsertDMData, ...) reply with an XML wrapper instead. That is still
      // a successful save, so return the raw text instead of throwing.
      try {
        return jsonDecode(response.body);
      } on FormatException {
        return response.body;
      }
    }
    print('HTTP ${response.statusCode} for $url');
    // Show the start of the server's error page — it names the real problem.
    final body = response.body;
    print('Server said: ${body.length > 800 ? body.substring(0, 800) : body}');
    throw Exception('Server returned ${response.statusCode}');
  }
}
