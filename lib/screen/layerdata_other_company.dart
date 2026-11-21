import 'package:autocomplete_textfield_ns/autocomplete_textfield_ns.dart';
import 'package:flutter/material.dart';
//import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'display_save_dm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:string_validator/string_validator.dart';
import '../constant/constants.dart';
import '../network/network.dart';
import '../models/customer.dart';
import '../widgets/rounded_button.dart';
import '../screen/supply_entry_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LayerScreen extends StatefulWidget {
  static const String id = 'LayerScreen';
  const LayerScreen({Key? key}) : super(key: key);

  @override
  State<LayerScreen> createState() => _LayerScreenState();
}

class _LayerScreenState extends State<LayerScreen> {
  final GlobalKey<ScaffoldState> ScafoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<AutoCompleteTextFieldState<Customer>> key = GlobalKey();
  double height = 10;

  final txtController = TextEditingController();
  final _supplyDateController = TextEditingController();
  final _hatchDateController = TextEditingController();
  final _totalChicksController = TextEditingController();
  final _transitMortalityController = TextEditingController();
  final _chickRateController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isDropDownFilled = true;
  List<String> added = [];
  List hatcheryName = [];
  List<String> customerList = [];
  List<Customer> customerList1 = [];
  DateTime selectedDate = DateTime.now();
  DateTime selectedHatchDate = DateTime.now();
  String? _dMNumber = '';
  String? _valueChicksType = "Broiler";
  String? _myValueHatchery = "Bovans";
  String? _MobileNumber = '';

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: selectedDate.subtract(Duration(days: 5, hours: 2)),
      lastDate: selectedDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _supplyDateController.text = selectedDate.toString().split(' ')[0];
      });
    } else {
      _supplyDateController.text = selectedDate.toString().split(' ')[0];
    }
  }

  _selectHatchDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedHatchDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
    );

    if (picked != null && picked != selectedHatchDate) {
      setState(() {
        selectedHatchDate = picked;
        _hatchDateController.text = selectedHatchDate.toString().split(' ')[0];
      });
    } else {
      _hatchDateController.text = selectedHatchDate.toString().split(' ')[0];
    }
  }

  void fetchDMNumber() async {
    try {
      Uri url =  Uri.parse('$Url/GetDMNumber?AreaCode=$AreaCode');
      NetworkHelper networkHelper = NetworkHelper(url);
      var data = await networkHelper.getData();
      // print(data);
      setState(() {
        if (data['DmNo'].length > 0) {
          _dMNumber = data['DmNo'][0]['DmNo'];
          print('dmno' + _dMNumber!);
        } else {
          _dMNumber = '-';
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        _dMNumber = '-';
      });
    }
  }

  void filCustomer() async {
    Uri url = Uri.parse('$Url/Customer?AreaCode=$AreaCode');
    NetworkHelper networkHelper = NetworkHelper(url);
    var data = await networkHelper.getData();

    for (var c in data['Customer']) {
      if (c['customer'].toString() != 'null') {
        // print(c['customer'].toString());
        customerList.add(c['customer'].toString());
        customerList1.add(Customer(customerName: c['customer'].toString()));
      }
    }
  }
  void fetchCustomerMobile(String code) async {
    try {
      Uri url = Uri.parse('$Url/GetMobileNumber?Code=$code');
      NetworkHelper networkHelper = NetworkHelper(url);
      var data = await networkHelper.getData();
      setState(() {
        if (data['MobileNo'].length > 0) {
          _MobileNumber = data['MobileNo'][0]['phone'];
          print('mobile' + _MobileNumber!);
        } else {
          _MobileNumber = '-';
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        _MobileNumber = '-';
      });
    }
  }
  void showSnackBar(String tittle) {
    final snackBar = SnackBar(
      content: Text(
        tittle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
    );
    // ScafoldKey.currentState!.showSnackBar(snackBar);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  addSupplyData() async {
    SharedPreferences shpSypply = await SharedPreferences.getInstance();
    shpSypply.setString('customerName', added[0]);
    shpSypply.setString('customerCode', added[1]);
    shpSypply.setString('mobile', _MobileNumber!);
    shpSypply.setString('dmno', _dMNumber!);
    shpSypply.setString('dmdate', _supplyDateController.text);
    shpSypply.setString('totalchicks', _totalChicksController.text);
    shpSypply.setString('transit_mortality',_transitMortalityController.text);
    shpSypply.setString('hatch_date',_hatchDateController.text);
    shpSypply.setString('hatchery',_myValueHatchery!);
    shpSypply.setString('chicks_type',_valueChicksType!);
    shpSypply.setString('rate',_chickRateController.text);
    shpSypply.setString('remark',_remarksController.text);
    print(shpSypply.getString('customerName'));
  }
  Future<void> saveLayerSupplyApi() async {
    try {
      final url = Uri.parse('$Url1/LayerDataOthCompany');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "customerName": added[0],
          "customerCode": added[1],
          "mobile": _MobileNumber,
          "dmno": _dMNumber,
          "dmdate": "1/1/2000",
          "totalchicks": _totalChicksController.text,
          "transit_mortality": _transitMortalityController.text,
          "hatch_date": _hatchDateController.text,
          "hatchery": _myValueHatchery,
          "chicks_type": _valueChicksType,
          "rate": _chickRateController.text,
          "remark": _remarksController.text,
          "AreaCode": AreaCode,
          "AreaName": AreaName
        }),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        print(data);

        showSnackBar("Supply Saved Successfully");
      } else {
        print(response.body);
        showSnackBar("Failed to save supply");
      }
    } catch (e) {
      print(e);
      showSnackBar("Server error");
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    //fetchDMNumber();
    filCustomer();
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ScafoldKey,
      appBar: AppBar(
        title: Text('LR Inforamtion Other Company'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello: $UserName   Area:$AreaName',
                style: const TextStyle(fontSize: 19),
                textAlign: TextAlign.left,
              ),
              const SizedBox(
                height: 5,
              ),
              const  Divider(
                height: 3,
                thickness: 1,
                color: Color(0xFFDCE7F1),
              ),
             const SizedBox(
                height: 20,
              ),
              Row(
                     children: [
                  Flexible(
                    flex: 6,
                    child: TextField(
                      readOnly: true,
                      controller: _hatchDateController,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      decoration: kTextFieldDecoration.copyWith(
                          labelText: 'Select Hatch Date'),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectHatchDate(context);
                      },
                    ),
                  )
                ],
              ),
             const SizedBox(
                height: 10,
              ),
              AutoCompleteTextField<Customer>(
                key: key,
                controller: txtController,
                clearOnSubmit: false,
                suggestions: customerList1,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontFamily: 'WorkSans',
                  fontWeight: FontWeight.w700,
                ),
                decoration: kTextFieldDecoration.copyWith(
                  labelText: 'Select Customer.',
                ),
                itemFilter: (item, query) {
                  return item.customerName!
                      .toLowerCase()
                      .startsWith(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a.customerName!.compareTo(b.customerName!);
                },
                itemSubmitted: (item) {
                  setState(() {
                    txtController.text = item.customerName!;
                    added = txtController.text.split('#');
                  });
                  fetchCustomerMobile(added[1]);
                  //print('Customer' + added[1]);
                },
                itemBuilder: (context, item) {
                  // ui for the autocomplete row
                  return row(item);
                },
              ),
              const SizedBox(
                height: 10,
              ),
               Text('Mobile: ' + _MobileNumber!),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Flexible(
                    flex: 20,
                    child: DropdownButton(
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                        dropdownColor: Colors.white,
                        value: _valueChicksType,
                        items: const [
                          DropdownMenuItem(
                            child: Text("Broiler"),
                            value: 'Broiler',
                          ),
                          DropdownMenuItem(
                            child: Text("Broiler(M)"),
                            value: 'Broiler(M)',
                          ),
                          DropdownMenuItem(
                            child: Text("Layer"),
                            value: 'Layer',
                          ),
                          DropdownMenuItem(
                            child: Text("Cockrel"),
                            value: 'Cockrel',
                          ),
                        ],
                        onChanged: (dynamic value) {
                          setState(() {
                            _valueChicksType = value;
                          });
                        }),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _totalChicksController,
                style: const TextStyle(color: Colors.black, fontSize: 18),
                decoration: kTextFieldDecoration.copyWith(
                    labelText: 'Enter Total Chicks'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _transitMortalityController,
                style:const TextStyle(color: Colors.black, fontSize: 18),
                decoration: kTextFieldDecoration.copyWith(
                    labelText: 'Enter Flock Age'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _chickRateController,
                style: const TextStyle(color: Colors.black, fontSize: 18),
                decoration: kTextFieldDecoration.copyWith(
                    labelText: 'Enter Flock Number'),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40.0,
                width: double.infinity,
                child:  DropdownButton(
                  style: const TextStyle(fontSize: 20, color: Colors.black),
            dropdownColor: Colors.white,
            value: _myValueHatchery,
            items:const [
              DropdownMenuItem(
                child: Text("Bovans"),
                value: 'Bovans',
              ),
              DropdownMenuItem(
                child: Text("Hyline"),
                value: 'Hyline',
              ),
              DropdownMenuItem(
                child: Text("Lohmann"),
                value: 'Lohmann',
              ),
              DropdownMenuItem(
                child: Text("Dekalb"),
                value: 'Dekalb',
              ),
             ],
            onChanged: (dynamic value) {
              setState(() {
                _myValueHatchery = value;
              });
            }),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _remarksController,
                style: TextStyle(fontSize: 16),
                decoration: kTextFieldDecoration.copyWith(labelText: 'Remarks'),
              ),
              const SizedBox(
                height: 20,
              ),
              RoundedButton(
                  title: 'Next...',
                  colour: Colors.lightBlueAccent,
                  onPressed: () async {
                    if (txtController.text.length <= 0) {
                      showSnackBar('Please provide a valid customer');
                      return;
                    }
                    //if (_supplyDateController.text.length <= 0) {
                      //showSnackBar('Please provide a valid Supply date');
                      //return;
                   // }
                    if (_hatchDateController.text.length <= 0) {
                      showSnackBar('Please provide a valid Hatch date');
                     // return;
                    }

                    if (_totalChicksController.text.length <= 0) {
                      showSnackBar('Please provide a valid number of chicks');
                      return;
                    }
                    else{
                      if(isNumeric(_totalChicksController.text)== true)
                      {        }
                      else
                      {
                        showSnackBar('Please provide a valid number of chicks');
                      }
                    }

                    if (_transitMortalityController.text.length <= 0) {
                      showSnackBar('Please provide a valid transit mortality');
                      return;
                    }
                    else{
                      if(isNumeric(_transitMortalityController.text)== true)
                      {        }
                      else
                      {
                        showSnackBar('Please provide a valid transit mortality');
                      }
                    }

                    if (_chickRateController.text.length <= 0) {
                      showSnackBar('Please provide a valid rate');
                      return;
                    }
                    else{
                      if(isNumeric(_chickRateController.text)== true)
                      {        }
                      else
                      {
                        showSnackBar('Please provide a valid rate');
                      }
                    }
                    saveLayerSupplyApi();

                    //Navigator.push(
                      //context,
                      //MaterialPageRoute(builder: (context) => saveLayerSupplyApi()),
                    //);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
