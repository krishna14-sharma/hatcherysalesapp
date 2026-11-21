import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constants.dart';
import '../models/customer.dart';
import '../network/network.dart';
import '../services/doc_number_service.dart';
import '../widgets/rounded_button.dart';
import '../widgets/ui.dart';
import 'display_save_dm.dart';

class SupplyEntryScreen extends StatefulWidget {
  static const String id = 'SupplyEntryScreen';

  @override
  _SupplyEntryScreenState createState() => _SupplyEntryScreenState();
}

class _SupplyEntryScreenState extends State<SupplyEntryScreen> {
  final GlobalKey<AutoCompleteTextFieldState<Customer>> key = GlobalKey();

  final txtController = TextEditingController();
  final _supplyDateController = TextEditingController();
  final _hatchDateController = TextEditingController();
  final _totalChicksController = TextEditingController();
  final _transitMortalityController = TextEditingController();
  final _chickRateController = TextEditingController();
  final _remarksController = TextEditingController();

  static const _chickTypes = ['Broiler', 'Broiler(M)', 'Layer', 'Cockrel'];

  bool _isDropDownFilled = false;
  List<String> added = [];
  String _selectedCustomerText = '';
  List<String> hatcheryName = [];
  List<Customer> customerList1 = [];
  DateTime selectedDate = DateTime.now();
  DateTime selectedHatchDate = DateTime.now();

  /// null until the server returns a real number.
  String? _dMNumber;
  bool _loadingNumber = true;
  String? _valueChicksType = 'Broiler';
  String? _myValueHatchery;
  String? _MobileNumber = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    fetchDMNumber();
    filCustomer();
    fillHatchery();
  }

  @override
  void dispose() {
    for (final c in [
      txtController,
      _supplyDateController,
      _hatchDateController,
      _totalChicksController,
      _transitMortalityController,
      _chickRateController,
      _remarksController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(DateTime d) => d.toString().split(' ')[0];

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now.subtract(const Duration(days: 5, hours: 2)),
      lastDate: now,
    );
    setState(() {
      if (picked != null) selectedDate = picked;
      _supplyDateController.text = _fmt(selectedDate);
    });
  }

  Future<void> _selectHatchDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedHatchDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );
    setState(() {
      if (picked != null) selectedHatchDate = picked;
      _hatchDateController.text = _fmt(selectedHatchDate);
    });
  }

  Future<void> fetchDMNumber() async {
    setState(() => _loadingNumber = true);
    final n = await DocNumberService.fetchDmNumber();
    if (!mounted) return;
    setState(() {
      _dMNumber = n;
      _loadingNumber = false;
    });
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

  Future<void> fillHatchery() async {
    try {
      final data = await NetworkHelper(DocNumberService.buildUri(
              'GetHatchriesList', {'AreaCode': AreaCode}))
          .getData();
      final list = <String>[];
      for (var c in data['Hatchries']) {
        if (c['Hatcheryies'].toString() != 'null') {
          list.add(c['Hatcheryies'].toString());
        }
      }
      if (!mounted) return;
      setState(() {
        hatcheryName = list;
        _myValueHatchery = list.isNotEmpty ? list.last : null;
        _isDropDownFilled = true;
      });
    } catch (e) {
      print('Hatchery load failed: $e');
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

  Future<void> addSupplyData() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('customerName', added[0]);
    await p.setString('customerCode', added[1]);
    await p.setString('mobile', _MobileNumber ?? '-');
    await p.setString('dmno', _dMNumber!);
    await p.setString('dmdate', _supplyDateController.text);
    await p.setString('totalchicks', _totalChicksController.text.trim());
    await p.setString('transit_mortality', _transitMortalityController.text.trim());
    await p.setString('hatch_date', _hatchDateController.text);
    await p.setString('hatchery', _myValueHatchery ?? '');
    await p.setString('chicks_type', _valueChicksType!);
    await p.setString('rate', _chickRateController.text.trim());
    await p.setString('remark', _remarksController.text.trim());
  }

  String? _validate() {
    if (_loadingNumber) return 'DM number is still loading, please wait';
    if (!DocNumberService.isValid(_dMNumber)) {
      return 'DM number not available. Tap Retry.';
    }
    if (added.length < 2 || txtController.text != _selectedCustomerText) {
      return 'Please select a customer from the list';
    }
    if (_supplyDateController.text.isEmpty) return 'Please select the supply date';
    if (_hatchDateController.text.isEmpty) return 'Please select the hatch date';
    if (!isPositiveNumber(_totalChicksController.text)) {
      return 'Please enter a valid number of chicks';
    }
    if (!isPositiveNumber(_transitMortalityController.text)) {
      return 'Please enter a valid transit mortality';
    }
    if (!isPositiveNumber(_chickRateController.text)) {
      return 'Please enter a valid rate';
    }
    return null;
  }

  Future<void> _onNext() async {
    final err = _validate();
    if (err != null) {
      showAppSnack(context, err);
      return;
    }
    setState(() => _busy = true);
    await addSupplyData();
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaveSupply()),
    );
  }

  Widget _numberField(TextEditingController c, String label, {IconData? icon}) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supply Information')),
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
                    label: 'DM Number',
                    number: _dMNumber,
                    loading: _loadingNumber,
                    onRetry: fetchDMNumber,
                  ),
                  const SizedBox(height: 16),
                  FormSection(
                    title: 'Dates',
                    icon: Icons.event_note_outlined,
                    children: [
                      DateField(
                        controller: _supplyDateController,
                        label: 'Chicks supply date',
                        onTap: _selectDate,
                      ),
                      DateField(
                        controller: _hatchDateController,
                        label: 'Hatch date',
                        onTap: _selectHatchDate,
                      ),
                    ],
                  ),
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
                        itemBuilder: (context, item) => row(item),
                      ),
                      MobileHint(_MobileNumber),
                    ],
                  ),
                  FormSection(
                    title: 'Supply details',
                    icon: Icons.local_shipping_outlined,
                    children: [
                      AppDropdown<String>(
                        label: 'Chick type',
                        icon: Icons.egg_outlined,
                        value: _valueChicksType,
                        items: _chickTypes,
                        onChanged: (v) => setState(() => _valueChicksType = v),
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: _numberField(
                                  _totalChicksController, 'Total chicks')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _numberField(
                                  _transitMortalityController, 'Mortality')),
                        ],
                      ),
                      _numberField(_chickRateController, 'Chick rate',
                          icon: Icons.currency_rupee),
                      _isDropDownFilled
                          ? AppDropdown<String>(
                              label: 'Hatchery',
                              icon: Icons.store_outlined,
                              value: _myValueHatchery,
                              items: hatcheryName,
                              onChanged: (v) =>
                                  setState(() => _myValueHatchery = v),
                            )
                          : const LinearProgressIndicator(minHeight: 2),
                      TextField(
                        controller: _remarksController,
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

/// Suggestion row for customer auto-complete.
/// Kept as a top-level function because layerdata_other_company.dart uses it.
Widget row(Customer maker) => customerSuggestionRow(maker.customerName!);
