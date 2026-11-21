import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:another_telephony/telephony.dart';

import '../services/whatsapp.dart';

import '../constant/constants.dart';
import '../network/network.dart';
import '../screen/menu_sales_screen.dart';
import '../services/doc_number_service.dart';
import '../theme/app_theme.dart';
import '../widgets/rounded_button.dart';
import '../widgets/ui.dart';

class SaveSupply extends StatefulWidget {
  static const String id = 'SaveSupply';
  @override
  _SaveSupplyState createState() => _SaveSupplyState();
}

class _SaveSupplyState extends State<SaveSupply> {
  static const _keys = [
    'customerName', 'customerCode', 'mobile', 'dmno', 'dmdate', 'totalchicks',
    'transit_mortality', 'hatch_date', 'hatchery', 'chicks_type', 'rate',
    'remark',
  ];

  final telephony = Telephony.instance;
  String? _MobileNumber = '';
  String? _CCode = '';
  String? _CName = '';
  String? _dmNumber = '';
  String? _dmDate = '';
  String? _totalChicks = '';
  String? _trasnitMortality = '';
  String? _hdate = '';
  String? _ctype = '';
  String? _remarks = '';
  String? _rate = '';
  String? _hatchery = '';

  bool _loaded = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    getSupplyData();
  }

  Future<void> getSupplyData() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      // Old code used getString('customerName')! — if that was null the
      // whole setState threw and DMNo (and everything else) stayed blank.
      _CName = p.getString('customerName') ?? '';
      _CCode = p.getString('customerCode') ?? '';
      _MobileNumber = p.getString('mobile') ?? '';
      _dmNumber = p.getString('dmno') ?? '';
      _dmDate = p.getString('dmdate') ?? '';
      _totalChicks = p.getString('totalchicks') ?? '';
      _trasnitMortality = p.getString('transit_mortality') ?? '';
      _hdate = p.getString('hatch_date') ?? '';
      _hatchery = p.getString('hatchery') ?? '';
      _ctype = p.getString('chicks_type') ?? '';
      _rate = p.getString('rate') ?? '';
      _remarks = p.getString('remark') ?? '';
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final nav = Navigator.of(context);
    setState(() => _isSaved = true);

    try {
      if (!await hasInternet()) {
        showAppSnack(context, 'Please check network connectivity');
        return;
      }

      // Fresh number, awaited, right before the insert.
      final fresh = await DocNumberService.fetchDmNumber();
      final dmNo = fresh ?? _dmNumber;
      if (!DocNumberService.isValid(dmNo)) {
        showAppSnack(context,
            'Could not get a DM number from the server. Nothing was saved — please try again.');
        return;
      }
      if (dmNo != _dmNumber) setState(() => _dmNumber = dmNo);

      if ((_CCode ?? '').isEmpty || (_totalChicks ?? '').isEmpty) {
        showAppSnack(context, 'Supply details are missing. Go back and re-enter.');
        return;
      }

      final url = DocNumberService.buildUri('InsertDMData', {
        'AreaCode': AreaCode,
        'Area': AreaName,
        'DMNo': dmNo,
        'DMDate': _dmDate,
        'HatchDate': _hdate,
        'uname': UserName,
        'Code': _CCode,
        'CName': _CName,
        'Chick_type': _ctype,
        'CihckRate': _rate,
        'Remarks': _remarks,
        'TotalChicks': _totalChicks,
        'Mortality': _trasnitMortality,
        'Hatchries': _hatchery,
      });

      try {
        final data = await NetworkHelper(url).getData();
        print(data);
      } catch (e) {
        print(e);
        showAppSnack(context, 'Save failed: could not reach the server. Please try again.');
        return;
      }

      Fluttertoast.showToast(
          msg: 'Supply $dmNo saved',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER);

      try {
        final msg =
            'Supplied $_ctype Chicks having Qty $_totalChicks With Transit Mortality $_trasnitMortality @ $_rate to $_CName  by DM $dmNo For Any Query Contact:9685043413 ';
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
        print(e);
      }

      final p = await SharedPreferences.getInstance();
      for (final k in _keys) {
        await p.remove(k);
      }
      // Old code popped this screen and then pushed using the dead context,
      // which threw — the user landed back on the entry form with the
      // already-used DM number still showing.
      nav.pushNamedAndRemoveUntil(SalesMenuGrid.id, (route) => false);
    } finally {
      if (mounted) setState(() => _isSaved = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Save Supply')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.headerGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.confirmation_number_outlined,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            (_dmNumber ?? '').isEmpty
                                ? 'DM number pending'
                                : _dmNumber!,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Text('${_totalChicks ?? ''} chicks',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_CName ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15)),
                      ],
                    ),
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
                    title: 'Supply',
                    icon: Icons.local_shipping_outlined,
                    children: [
                      Column(children: [
                        InfoRow('DM date', _dmDate),
                        InfoRow('Hatch date', _hdate),
                        InfoRow('Chick type', _ctype),
                        InfoRow('Total chicks', _totalChicks),
                        InfoRow('Transit mortality', _trasnitMortality),
                        InfoRow('Rate', _rate),
                        InfoRow('Hatchery', _hatchery),
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
                        title: 'Save Supply',
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
