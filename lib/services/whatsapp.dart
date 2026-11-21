import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp with [text] ready to send to [phone].
///
/// Replaces flutter_plugin_openwhatsapp (unmaintained; it doesn't build with
/// current Android Gradle Plugin). Uses the official wa.me link instead.
/// 10-digit Indian numbers get the 91 country code automatically.
Future<bool> openWhatsApp({required String phone, required String text}) async {
  var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11 && digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length == 10) digits = '91$digits';
  if (digits.isEmpty) return false;

  final uri = Uri.parse('https://wa.me/$digits')
      .replace(queryParameters: {'text': text});
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    print('WhatsApp open failed: $e');
    return false;
  }
}
