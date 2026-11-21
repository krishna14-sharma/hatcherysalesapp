import 'package:connectivity_plus/connectivity_plus.dart';

import '../constant/constants.dart';
import '../network/network.dart';

/// Single place that fetches TR / DM numbers and builds safe request URLs.
///
/// Why this exists — the old code that caused blank TRNo / DMNo in the DB:
///  * The number was fetched in the background and nothing waited for it.
///    The field started as '' and "Next" never checked it, so a slow or
///    failed lookup sent an empty number.
///  * The save screen called fetchTRNumber()/fetchDMNumber() WITHOUT await,
///    so the fresh number never reached the insert call.
///  * If anything in the hand-off between screens threw (customer typed but
///    not picked from the list, bank name without '#'), the save screen kept
///    its initial '' values and still saved.
///  * URLs were glued together by hand, so a '#', '&' or '+' in any value
///    (customer name, remarks, area...) cut off or corrupted the request.
class DocNumberService {
  DocNumberService._();

  /// True only for a real number returned by the server.
  static bool isValid(String? number) {
    if (number == null) return false;
    final n = number.trim();
    return n.isNotEmpty && n != '-' && n.toLowerCase() != 'null';
  }

  /// Next TR number for the current area, or null if it couldn't be fetched.
  static Future<String?> fetchTrNumber() =>
      _fetch('GetTRNumber', listKey: 'TrNo', fieldKeys: const ['trno', 'TrNo', 'TRNo']);

  /// Next DM number for the current area, or null if it couldn't be fetched.
  static Future<String?> fetchDmNumber() =>
      _fetch('GetDMNumber', listKey: 'DmNo', fieldKeys: const ['DmNo', 'dmno', 'DMNo']);

  /// Next chicks-demand number for the current area, or null.
  static Future<String?> fetchDemandNumber() => _fetch('GetDemandNo',
      listKey: 'DemandNo', fieldKeys: const ['DemandNo', 'demandno']);

  static Future<String?> _fetch(String endpoint,
      {required String listKey, required List<String> fieldKeys}) async {
    try {
      final data = await NetworkHelper(
        buildUri(endpoint, {'AreaCode': AreaCode ?? ''}),
      ).getData();
      final list = data is Map ? data[listKey] : null;
      if (list is List && list.isNotEmpty && list.first is Map) {
        final row = list.first as Map;
        for (final k in fieldKeys) {
          // .toString() — the server may send a number, not a string.
          final value = row[k]?.toString().trim();
          if (isValid(value)) return value;
        }
      }
      print('$endpoint returned no usable number: $data');
    } catch (e) {
      print('$endpoint failed: $e');
    }
    return null;
  }

  /// Builds `<Url>/<endpoint>?k=v&...` with every value properly encoded.
  ///
  /// Every parameter is always written as `name=value`, even when the value
  /// is empty (`Remarks=`). Dart's own Uri(queryParameters:) writes an empty
  /// value as just `Remarks`, which the .asmx service treats as a missing
  /// parameter and answers with HTTP 500.
  static Uri buildUri(String endpoint, Map<String, String?> params) {
    final query = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value ?? '')}')
        .join('&');
    return Uri.parse('$Url/$endpoint?$query');
  }
}

/// Works with both old (single result) and new (list) connectivity_plus APIs.
Future<bool> hasInternet() async {
  try {
    final dynamic result = await Connectivity().checkConnectivity();
    if (result is List) {
      return result.any((r) => r != ConnectivityResult.none);
    }
    return result != ConnectivityResult.none;
  } catch (_) {
    return true; // don't block the user if the plugin itself fails
  }
}
