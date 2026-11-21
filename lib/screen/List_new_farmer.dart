import 'package:flutter/material.dart';
import '../constant/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class NewCustomer {
  final String? CustName;
  final String? CustAddress;
  final String? CustPhone;
  final String? State;
  final String? City;
  final String? PAN;
  final String? AADHAR;
  final String? GSTIN;
  NewCustomer(
      {this.CustName,
      this.CustAddress,
      this.CustPhone,
      this.State,
      this.City,
      this.PAN,
      this.AADHAR,
      this.GSTIN});
}

class

ListNewCustomer extends StatefulWidget {
  static const String id = 'ListNewFarmer';
  @override
  _ListNewCustomerState createState() => _ListNewCustomerState();
}

class _ListNewCustomerState extends State<ListNewCustomer> {
  List<NewCustomer> newCustomerList = [];

  void getListFarmaer() async {
    var url = Uri.http(Url2,
        '/api/AreaCustomer/GetNewCustomer/$AreaCode', {'q': '{http}'});
    print(url);
    var response = await http.get(url);

    if (response.statusCode == 200) {
      print('data');
      var data = convert.jsonDecode(response.body);
      for (var c in data) {
        setState(() {
          newCustomerList.add(NewCustomer(
            CustName: c["CustName"].toString(),
            CustAddress: c["CustAddress"].toString(),
            CustPhone: c["CustPhone"].toString(),
            State: c["State"].toString(),
            City: c["City"].toString(),
            PAN: c["PAN"].toString(),
            AADHAR: c["AADHAR"].toString(),
            GSTIN: c["GSTIN"].toString(),
          ));
        });

        // print(c["CustName"].toString());
      }
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    getListFarmaer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List New Farmer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              'Hello: $UserName   Area:$AreaName',
              style: const TextStyle(fontSize: 19),
              textAlign: TextAlign.left,
            ),
            const SizedBox(
              height: 5,
            ),
            const Divider(
              height: 3,
              thickness: 1,
              color: Color(0xFFDCE7F1),
            ),
            Expanded(child:   ListView.builder(
              itemBuilder: (context, index) => Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name:${newCustomerList[index].CustName}'),
                    Text('Address:${newCustomerList[index].CustAddress}'),
                    Text('Phone:${newCustomerList[index].CustPhone}'),
                    Text('PAN:${newCustomerList[index].PAN}'),
                    const Divider(
                      height: 3,
                      thickness: 1,
                      color: Color(0xFFDCE7F1),
                    ),
                    const SizedBox(height: 5,)
                  ],
                ),
              ),
              itemCount: newCustomerList.length,
            ),
            ),

          ],
        ),
      ),
    );
  }
}
