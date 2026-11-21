import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../constant/constants.dart';
import '../services/doc_number_service.dart';
import '../data/india_cities.dart';
import 'dart:convert';

class NewCustomeradd extends StatefulWidget {
  static const id = 'NewCustomeradd';
  @override
  _NewCustomeraddState createState() => _NewCustomeraddState();
}

class _NewCustomeraddState extends State<NewCustomeradd> {
  final GlobalKey<ScaffoldState> ScafoldKey = new GlobalKey<ScaffoldState>();

  final _custName = TextEditingController();
  final _custAddress = TextEditingController();
  final _custMobile = TextEditingController();
  final _custPAN = TextEditingController();
  final _custGST = TextEditingController();
  final _custAADHAR = TextEditingController();

  String? countryValue = "India";
  String? stateValue = "";
  String? cityValue = "";
  String? address = "";
  bool _isSaved = false;

  void showSnackBar(String tittle) {
    final snackBar = SnackBar(
      content: Text(
        tittle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ScafoldKey,
      appBar: AppBar(
        title: const Text("New Farmer"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:const  EdgeInsets.all(8),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _custName,
                maxLength: 50,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'What do people call you?',
                  labelText: 'Customer Name *',
                ),
              ),
             const SizedBox(
                height: 3,
              ),
              TextFormField(
                controller: _custAddress,
                maxLines: 3,
                maxLength: 100,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  icon: Icon(Icons.add_location),
                  hintText: 'What is Address?',
                  labelText: 'Customer Address *',
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              TextFormField(
                controller: _custMobile,
                maxLength: 10,
                decoration: const InputDecoration(
                  icon: Icon(Icons.mobile_friendly),
                  hintText: 'Mobile/Phone?',
                  labelText: 'Mobile *',
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              TextFormField(
                controller: _custPAN,
                maxLength: 10,
                decoration: const InputDecoration(
                  icon: Icon(Icons.confirmation_number),
                  hintText: 'PAN?',
                  labelText: 'Customer PAN *',
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              TextFormField(
                controller: _custGST,
                maxLength: 16,
                decoration: const InputDecoration(
                  icon: Icon(Icons.confirmation_number),
                  hintText: 'GSTIN?',
                  labelText: 'Customer GST Number *',
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              TextFormField(
                controller: _custAADHAR,
                maxLength: 16,
                decoration: const InputDecoration(
                  icon: Icon(Icons.sports_baseball),
                  hintText: 'AADHAR?',
                  labelText: 'Customer AADHAR*',
                ),
              ),
              const SizedBox(
                height: 0,
              ),
              // State, then City (country is always India). Both open a
              // searchable list; City shows only the chosen state's cities.
              _PickerField(
                label: 'State*',
                icon: Icons.map_outlined,
                value: stateValue,
                options: kIndiaStateCities.keys.toList(),
                onSelected: (v) => setState(() {
                  if (v != stateValue) {
                    stateValue = v;
                    cityValue = '';
                  }
                }),
              ),
              const SizedBox(height: 12),
              _PickerField(
                label: 'City*',
                icon: Icons.location_city_outlined,
                value: cityValue,
                enabled: (stateValue ?? '').isNotEmpty,
                disabledHint: 'Select a state first',
                options: kIndiaStateCities[stateValue] ?? const [],
                onSelected: (v) => setState(() => cityValue = v),
              ),
              const SizedBox(
                height: 10,
              ),
             _isSaved ?  const CircularProgressIndicator(strokeWidth:5,) : const Text(".")

            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!await hasInternet()) {
            Fluttertoast.showToast(msg : "TNo internet connectivity", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
            return;
          }


          if (_custName.text.isEmpty) {
            showSnackBar('Please provide a valid Farmer name');
            return;
          }

          if (_custAddress.text.isEmpty) {
            showSnackBar('Please provide a valid Farmer address');
            return;
          }

          if (_custMobile.text.isEmpty) {
            showSnackBar('Please provide a valid Farmer mobile');
            return;
          }

          if (stateValue == null || stateValue!.isEmpty) {
            showSnackBar('Please provide a valid State');
            return;
          }

          if (cityValue == null || cityValue!.trim().isEmpty) {
            showSnackBar('Please provide a valid City');
            return;
          }

          try {

            var uriResponse = await http.post(
               Uri.parse('$Url1/AreaCustomer'),
                headers: {"Content-type": "application/json"},
                body: jsonEncode({
                  "custName": _custName.text,
                  "custAddress": _custAddress.text,
                  "custPhone": _custMobile.text,
                  "state": stateValue,
                  "city": cityValue,
                  "pan": _custPAN.text,
                  "aadhar": _custAADHAR.text,
                  "gstin": _custGST.text,
                  "areaCode": AreaCode,
                  "area": AreaName,
                  "userName": UserName,
                  "entryDate": DateTime.now().toIso8601String()
                }));
            print( jsonDecode(uriResponse.body));
            print("2");


            Fluttertoast.showToast(msg : "Farmer Data Saved...", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.CENTER);
            setState(() {
              _isSaved = true;
            });
            Navigator.pop(context);
          }
          catch(e){
            print(e.toString());
          }
          finally {

          }
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}


/// Read-only field that opens a searchable list in a bottom sheet.
class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onSelected,
    this.enabled = true,
    this.disabledHint,
  });

  final String label;
  final IconData icon;
  final String? value;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool enabled;
  final String? disabledHint;

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _SearchList(title: label.replaceAll('*', ''), options: options),
    );
    if (picked != null) onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final has = (value ?? '').isNotEmpty;
    return InkWell(
      onTap: enabled ? () => _open(context) : null,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        isEmpty: !has,
        decoration: InputDecoration(
          labelText: label,
          hintText: enabled ? null : disabledHint,
          enabled: enabled,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(has ? value! : '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _SearchList extends StatefulWidget {
  const _SearchList({required this.title, required this.options});
  final String title;
  final List<String> options;

  @override
  State<_SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<_SearchList> {
  String _q = '';

  /// Matches ignoring case and accents, so "ambikapur" finds "Ambikāpur".
  static String _plain(String s) {
    const from = 'āáàâäãīíìîïūúùûüēéèêëōóòôöõṇñṛṣśṭḍḥṁ';
    const to   = 'aaaaaaiiiiiuuuuueeeeeoooooonnrsstdhm';
    final b = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      final i = from.indexOf(ch);
      b.write(i >= 0 ? to[i] : ch);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final q = _plain(_q.trim());
    final items = q.isEmpty
        ? widget.options
        : widget.options.where((o) => _plain(o).contains(q)).toList();
    final h = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: h * 0.75,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDCE7F1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Search ${widget.title.toLowerCase()}',
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('No match'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) => ListTile(
                        title: Text(items[i]),
                        onTap: () => Navigator.pop(context, items[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
