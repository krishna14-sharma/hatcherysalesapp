import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_telephony/telephony.dart';

import '../services/whatsapp.dart';

import '../constant/constants.dart';
import '../network/network.dart';
import '../services/doc_number_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rounded_button.dart';
import '../widgets/ui.dart';
import 'menu_sales_screen.dart';

class DisplayAndSaveTR extends StatefulWidget {
  @override
  _DisplayAndSaveTRState createState() => _DisplayAndSaveTRState();
}

class _DisplayAndSaveTRState extends State<DisplayAndSaveTR> {
  static const _keys = [
    'customerName', 'customerCode', 'mobile', 'trno', 'trdate', 'tramount',
    'paymode', 'ddno', 'bank_det', 'pay_type', 'hatch_date', 'chicks_type',
    'rate', 'remark', 'bankdate',
  ];

  final telephony = Telephony.instance;
  String bd1 = '', bd2 = '';
  String? _MobileNumber = '';
  String? _CCode = '';
  String? _CName = '';
  String? _TRNumber = '';
  String? _Trdate = '';
  String? _Tramount = '';
  String? _paymode = '';
  String? _DdNo = '';
  String? _bankdet = '';
  String? _paytype = '';
  String? _hdate = '';
  String? _ctype = '';
  String? _remarks = '';
  String? _rate = '';
  String? _bankdate = '';

  bool _loaded = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    getTRData();
  }

  Future<void> getTRData() async {
    final prefs = await SharedPreferences.getInstance();
    final bank = prefs.getString('bank_det') ?? '';
    // Old code did split('#')[1] unguarded — a bank name without '#'
    // threw here, the setState below never ran and every field (TRNo
    // included) stayed blank but was still saved.
    final parts = bank.split('#');
    if (!mounted) return;
    setState(() {
      bd1 = parts[0];
      bd2 = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _CCode = prefs.getString('customerCode') ?? '';
      _CName = prefs.getString('customerName') ?? '';
      _MobileNumber = prefs.getString('mobile') ?? '';
      _TRNumber = prefs.getString('trno') ?? '';
      _Trdate = prefs.getString('trdate') ?? '';
      _Tramount = prefs.getString('tramount') ?? '';
      _paymode = prefs.getString('paymode') ?? '';
      _DdNo = prefs.getString('ddno') ?? '';
      _bankdet = bank;
      _paytype = prefs.getString('pay_type') ?? '';
      _hdate = prefs.getString('hatch_date') ?? '';
      _ctype = prefs.getString('chicks_type') ?? '';
      _remarks = prefs.getString('remark') ?? '';
      _rate = prefs.getString('rate') ?? '';
      _bankdate = prefs.getString('bankdate') ?? '';
      _loaded = true;
    });
  }

  void _toast(String msg) => Fluttertoast.showToast(
      msg: msg, toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);

  Future<void> _save() async {
    final nav = Navigator.of(context);
    setState(() => _isSaved = true);

    try {
      if (!await hasInternet()) {
        showAppSnack(context, 'No internet connectivity');
        return;
      }

      // Get a fresh number right before inserting (awaited this time) so
      // the value sent is never blank and never one another user just took.
      final fresh = await DocNumberService.fetchTrNumber();
      final trNo = fresh ?? _TRNumber;
      if (!DocNumberService.isValid(trNo)) {
        showAppSnack(context,
            'Could not get a TR number from the server. Nothing was saved — please try again.');
        return;
      }
      if (trNo != _TRNumber) setState(() => _TRNumber = trNo);

      if ((_CCode ?? '').isEmpty || (_Tramount ?? '').isEmpty) {
        showAppSnack(context, 'TR details are missing. Go back and re-enter.');
        return;
      }

      final url = DocNumberService.buildUri('InsertTrData', {
        'AreaCode': AreaCode,
        'Area': AreaName,
        'TRNo': trNo,
        'TrDate': _Trdate,
        'HatchDate': _hdate,
        'uname': UserName,
        'Code': _CCode,
        'CName': _CName,
        'Pay_mode': _paymode,
        'DD_No': _DdNo,
        'Bank_det': bd2.isEmpty ? bd1 : '$bd1 $bd2',
        'Pay_type': _paytype,
        'Chick_type': _ctype,
        'CihckRate': _rate,
        'Remarks': _remarks,
        'TrAmount': _Tramount,
        'bankdate': _bankdate,
      });

      try {
        await NetworkHelper(url).getData();
      } catch (e) {
        print('Errdatasave $e');
        showAppSnack(context, 'Save failed: could not reach the server. Please try again.');
        return;
      }

      _toast('TR $trNo saved');

      try {
        final msg =
            'Note:Temporary Receipt: Received with thanks $_paymode on $_bankdate Rs:$_Tramount @ $_rate ';
        final to = _MobileNumber ?? '';
        if (to.isNotEmpty && to != '-') {
          await telephony.sendSms(
            to: to,
            message: msg,
            statusListener: (s) => print(s.name),
          );
          final result = await openWhatsApp(phone: to, text: msg);
          debugPrint('>>>: $result');
        }
      } catch (e) {
        print('Errsendsms $e');
      }

      final prefs = await SharedPreferences.getInstance();
      for (final k in _keys) {
        await prefs.remove(k);
      }
      nav.pushNamedAndRemoveUntil(SalesMenuGrid.id, (route) => false);
    } finally {
      if (mounted) setState(() => _isSaved = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Save TR')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AmountHero(
                    number: _TRNumber,
                    amount: _Tramount,
                    customer: _CName,
                  ),
                  const SizedBox(height: 16),
                  FormSection(
                    title: 'Customer',
                    icon: Icons.person_outline,
                    children: [
                      Column(children: [
                        InfoRow('Code', _CCode),
                        InfoRow('Name', _CName),
                        InfoRow('Mobile', _MobileNumber),
                      ]),
                    ],
                  ),
                  FormSection(
                    title: 'Payment',
                    icon: Icons.payments_outlined,
                    children: [
                      Column(children: [
                        InfoRow('TR date', _Trdate),
                        InfoRow('Mode', _paymode),
                        InfoRow('Chq / Ref no.', _DdNo),
                        InfoRow('Bank', _bankdet?.replaceAll('#', ' • ')),
                        InfoRow('Deposit date', _bankdate),
                        InfoRow('Payment type', _paytype),
                      ]),
                    ],
                  ),
                  FormSection(
                    title: 'Chicks',
                    icon: Icons.egg_outlined,
                    children: [
                      Column(children: [
                        InfoRow('Hatch date', _hdate),
                        InfoRow('Chick type', _ctype),
                        InfoRow('Rate', _rate),
                        InfoRow('Remarks', _remarks),
                      ]),
                    ],
                  ),
                  if (_isSaved)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    RoundedButton(
                        title: 'Save TR',
                        icon: Icons.check_circle_outline,
                        onPressed: _save),
                    RoundedButton(
                        title: 'Previous',
                        onPressed: () => Navigator.pop(context)),
                  ],
                ],
              ),
            ),
    );
  }
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({this.number, this.amount, this.customer});

  final String? number;
  final String? amount;
  final String? customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.confirmation_number_outlined,
                  color: Colors.white70, size: 18),
              const SizedBox(width: 6),
              Text(
                (number == null || number!.isEmpty) ? 'TR number pending' : number!,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('₹ ${amount ?? ''}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(customer ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }
}
