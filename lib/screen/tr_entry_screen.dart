import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constants.dart';
import '../models/customer.dart';
import '../network/network.dart';
import '../screen/display_save_tr.dart';
import '../services/doc_number_service.dart';
import '../widgets/rounded_button.dart';
import '../widgets/ui.dart';

class TrEntryScreen extends StatefulWidget {
  static const id = 'TrEntry';
  @override
  _TrEntryScreenState createState() => _TrEntryScreenState();
}

class _TrEntryScreenState extends State<TrEntryScreen> {
  final GlobalKey<AutoCompleteTextFieldState<Customer>> key = GlobalKey();

  final txtController = TextEditingController();
  final _trDateController = TextEditingController();
  final _trAmountController = TextEditingController();
  final _chqNumberController = TextEditingController();
  final _bandepositDateController = TextEditingController();
  final _hatchDateController = TextEditingController();
  final _chickrateController = TextEditingController();
  final _reamrkController = TextEditingController();

  static const _payModes = ['CHEQUE', 'CASH', 'TRANSFER', 'RTGS', 'NEFT'];
  static const _paymentTypes = ['Old-Payment', 'Current-Payment', 'Advance-Payment'];
  static const _chickTypes = ['Broiler', 'Broiler(M)', 'Layer', 'Cockrel'];

  List<String> added = [];
  String _selectedCustomerText = '';
  List<String> bankName = [];
  List<Customer> customerList1 = [];
  String? _MobileNumber = '';

  /// null until the server returns a real number.
  String? _TRNumber;
  bool _loadingNumber = true;

  DateTime selectedDate = DateTime.now();
  DateTime selectedHatchDate = DateTime.now();
  DateTime bankdepositselectedDate = DateTime.now();
  String? _value = 'CHEQUE';
  String? _myValuebank;
  String? _myValuePaymentType = 'Current-Payment';
  String? _valueChicksType = 'Broiler';
  bool _isDropDownFilled = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // initState runs once — didChangeDependencies (used before) can run
    // several times and re-fetched / duplicated the lists.
    filCustomer();
    fillBank();
    fetchTRNumber();
  }

  @override
  void dispose() {
    for (final c in [
      txtController,
      _trDateController,
      _trAmountController,
      _chqNumberController,
      _bandepositDateController,
      _hatchDateController,
      _chickrateController,
      _reamrkController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> filCustomer() async {
    try {
      final data = await NetworkHelper(
              DocNumberService.buildUri('Customer', {'AreaCode': AreaCode}))
          .getData();
      final list = <Customer>[];
      for (var c in data['Customer']) {
        if (c['customer'].toString() != 'null') {
          list.add(Customer(customerName: c['customer'].toString()));
        }
      }
      if (!mounted) return;
      setState(() {
        customerList1
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      print('Customer load failed: $e');
    }
  }

  Future<void> fillBank() async {
    try {
      final data = await NetworkHelper(
              DocNumberService.buildUri('Bankname', {'AreaCode': AreaCode}))
          .getData();
      final list = <String>[];
      for (var c in data['Bank']) {
        if (c['bank'].toString() != 'null') list.add(c['bank'].toString());
      }
      if (!mounted) return;
      setState(() {
        bankName = list;
        _myValuebank = list.isNotEmpty ? list.last : null;
        _isDropDownFilled = true;
      });
    } catch (e) {
      print('Bank load failed: $e');
      if (mounted) setState(() => _isDropDownFilled = true);
    }
  }

  Future<void> fetchCustomerMobile(String code) async {
    String mobile = '-';
    try {
      final data = await NetworkHelper(
              DocNumberService.buildUri('GetMobileNumber', {'Code': code}))
          .getData();
      if (data['MobileNo'].length > 0) {
        mobile = data['MobileNo'][0]['phone']?.toString() ?? '-';
      }
    } catch (e) {
      print(e);
    }
    if (mounted) setState(() => _MobileNumber = mobile);
  }

  Future<void> fetchTRNumber() async {
    setState(() => _loadingNumber = true);
    final n = await DocNumberService.fetchTrNumber();
    if (!mounted) return;
    setState(() {
      _TRNumber = n;
      _loadingNumber = false;
    });
  }

  Future<DateTime?> _pick(DateTime initial, DateTime first, DateTime last) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
  }

  String _fmt(DateTime d) => d.toString().split(' ')[0];

  Future<void> _selectDate() async {
    final picked = await _pick(selectedDate, selectedDate, selectedDate);
    setState(() {
      if (picked != null) selectedDate = picked;
      _trDateController.text = _fmt(selectedDate);
    });
  }

  Future<void> _bankdepositselectDate() async {
    final picked = await _pick(
        bankdepositselectedDate, DateTime(2024), DateTime(2035));
    setState(() {
      if (picked != null) bankdepositselectedDate = picked;
      _bandepositDateController.text = _fmt(bankdepositselectedDate);
    });
  }

  Future<void> _selectHatchDate() async {
    final picked =
        await _pick(selectedHatchDate, DateTime(2000), DateTime(2035));
    setState(() {
      if (picked != null) selectedHatchDate = picked;
      _hatchDateController.text = _fmt(selectedHatchDate);
    });
  }

  /// Awaited now — previously navigation happened before this finished.
  Future<void> addStringToSF() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customerName', added[0]);
    await prefs.setString('customerCode', added[1]);
    await prefs.setString('mobile', _MobileNumber ?? '-');
    await prefs.setString('trno', _TRNumber!);
    await prefs.setString('trdate', _trDateController.text);
    await prefs.setString('tramount', _trAmountController.text.trim());
    await prefs.setString('paymode', _value!);
    await prefs.setString('ddno', _chqNumberController.text.trim());
    await prefs.setString('bank_det', _myValuebank ?? '');
    await prefs.setString('pay_type', _myValuePaymentType!);
    await prefs.setString('hatch_date', _hatchDateController.text);
    await prefs.setString('chicks_type', _valueChicksType!);
    await prefs.setString('rate', _chickrateController.text.trim());
    await prefs.setString('remark', _reamrkController.text.trim());
    await prefs.setString('bankdate', _bandepositDateController.text);
  }

  String? _validate() {
    if (_loadingNumber) return 'TR number is still loading, please wait';
    if (!DocNumberService.isValid(_TRNumber)) {
      return 'TR number not available. Tap Retry.';
    }
    if (added.length < 2 || txtController.text != _selectedCustomerText) {
      return 'Please select a customer from the list';
    }
    if (_trDateController.text.isEmpty) return 'Please select the TR date';
    if (!isPositiveNumber(_trAmountController.text)) {
      return 'Please enter a valid TR amount';
    }
    if (_bandepositDateController.text.isEmpty) {
      return 'Please select the bank deposit date';
    }
    if (_hatchDateController.text.isEmpty) return 'Please select the hatch date';
    if (!isPositiveNumber(_chickrateController.text)) {
      return 'Please enter a valid chick rate';
    }
    return null;
  }

  Future<void> _onNext() async {
    if (!await hasInternet()) {
      showAppSnack(context, 'No internet connectivity');
      return;
    }
    final err = _validate();
    if (err != null) {
      showAppSnack(context, err);
      return;
    }
    setState(() => _busy = true);
    await addStringToSF();
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DisplayAndSaveTR()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TR Creation')),
      body: Column(
        children: [
          const UserHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DocNumberBanner(
                    label: 'TR Number',
                    number: _TRNumber,
                    loading: _loadingNumber,
                    onRetry: fetchTRNumber,
                  ),
                  const SizedBox(height: 16),
                  FormSection(
                    title: 'Customer',
                    icon: Icons.person_outline,
                    children: [
                      AutoCompleteTextField<Customer>(
                        key: key,
                        controller: txtController,
                        clearOnSubmit: false,
                        suggestions: customerList1,
                        style: const TextStyle(fontSize: 16),
                        decoration: const InputDecoration(
                          labelText: 'Search customer',
                          prefixIcon: Icon(Icons.search),
                        ),
                        itemFilter: (item, query) => item.customerName!
                            .toLowerCase()
                            .startsWith(query.toLowerCase()),
                        itemSorter: (a, b) =>
                            a.customerName!.compareTo(b.customerName!),
                        itemSubmitted: (item) {
                          final parts = item.customerName!.split('#');
                          setState(() {
                            txtController.text = item.customerName!;
                            _selectedCustomerText = item.customerName!;
                            added = parts;
                            _MobileNumber = '';
                          });
                          if (parts.length > 1) fetchCustomerMobile(parts[1]);
                        },
                        itemBuilder: (context, item) =>
                            customerSuggestionRow(item.customerName!),
                      ),
                      MobileHint(_MobileNumber),
                    ],
                  ),
                  FormSection(
                    title: 'Payment',
                    icon: Icons.payments_outlined,
                    children: [
                      DateField(
                        controller: _trDateController,
                        label: 'TR date',
                        onTap: _selectDate,
                      ),
                      TextField(
                        controller: _trAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'TR amount',
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                      ),
                      AppDropdown<String>(
                        label: 'Payment mode',
                        icon: Icons.account_balance_wallet_outlined,
                        value: _value,
                        items: _payModes,
                        onChanged: (v) => setState(() => _value = v),
                      ),
                      TextField(
                        controller: _chqNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Cheque / NEFT / RTGS number',
                          prefixIcon: Icon(Icons.tag),
                        ),
                      ),
                      _isDropDownFilled
                          ? AppDropdown<String>(
                              label: 'Bank',
                              icon: Icons.account_balance_outlined,
                              value: _myValuebank,
                              items: bankName,
                              itemLabel: (b) => b.replaceAll('#', ' • '),
                              onChanged: (v) =>
                                  setState(() => _myValuebank = v),
                            )
                          : const LinearProgressIndicator(minHeight: 2),
                      DateField(
                        controller: _bandepositDateController,
                        label: 'Bank deposit date',
                        onTap: _bankdepositselectDate,
                      ),
                      AppDropdown<String>(
                        label: 'Payment type',
                        icon: Icons.receipt_long_outlined,
                        value: _myValuePaymentType,
                        items: _paymentTypes,
                        onChanged: (v) =>
                            setState(() => _myValuePaymentType = v),
                      ),
                    ],
                  ),
                  FormSection(
                    title: 'Chicks',
                    icon: Icons.egg_outlined,
                    children: [
                      DateField(
                        controller: _hatchDateController,
                        label: 'Hatch date',
                        onTap: _selectHatchDate,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Chick type',
                              value: _valueChicksType,
                              items: _chickTypes,
                              onChanged: (v) =>
                                  setState(() => _valueChicksType = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _chickrateController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration:
                                  const InputDecoration(labelText: 'Rate'),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _reamrkController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Remarks',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _busy
                      ? const Center(child: CircularProgressIndicator())
                      : RoundedButton(title: 'Next', onPressed: _onNext),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
