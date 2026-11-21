import 'package:flutter/material.dart';
import '../network/network.dart';
import '../constant/constants.dart';
import '../widgets/rounded_button.dart';
import '../screen/Pdf_tr.dart';

class ListTr {
  final String? TrNo;
  final String? TrDate;
  final String? Amount;
  final String? CCode;
  final String? CName;
  final String? Ctype;
  final String? bankdet;
  final String? hatchdate;
  final String? paytype;
  final String? rate;
  final String? bankdate;
  ListTr(
      {this.TrNo,
      this.TrDate,
      this.Amount,
      this.CCode,
      this.CName,
      this.Ctype,this.bankdet,this.hatchdate,this.paytype,this.rate,this.bankdate});
}

class ListTrData extends StatefulWidget {
  static const String id = 'ListTrData';
  @override
  _ListTrDataState createState() => _ListTrDataState();
}

class _ListTrDataState extends State<ListTrData> {
  final _trDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<ListTr> trList = [];
  bool _isDropDownFilled = false;

  void fillTrData() async {
    Uri url =
       Uri.parse('$Url/ShowTrData?AreaCode=$AreaCode&uname=$UserName&TrDate=${_trDateController.text}');
    print(url);
    NetworkHelper networkHelper = NetworkHelper(url);
    var data = await networkHelper.getData();
    trList.clear();
    //print(data);
    for (var c in data['TrData']) {
      if (c['TRNo'].toString() != 'null') {
        setState(() {
          trList.add(ListTr(
            TrNo: c['TRNo'].toString(),
            TrDate: c['TrDate'].toString(),
            Amount: c['TrAmount'].toString(),
            CCode: c['Code'].toString(),
            CName: c['CName'].toString(),
            Ctype: c['Chick_type'].toString(),
            bankdet: c['Bank_det'].toString(),
            hatchdate: c['HatchDate'].toString(),
            paytype: c['Pay_mode'].toString(),
            rate: c['Rate'].toString(),
            bankdate: c['bankdate'].toString()
          ));
        });
      }
    }
    _isDropDownFilled = true;
    // print(trList[0].CName);
  }

  void fillAllTrData() async {
    Uri url =
       Uri.parse('$Url/ShowAllTrData?AreaCode=$AreaCode&uname=$UserName');
    print(url);
    NetworkHelper networkHelper = NetworkHelper(url);
    var data = await networkHelper.getData();
    //print(data);
    trList.clear();
    for (var c in data['TrData']) {
      if (c['TRNo'].toString() != 'null') {
        setState(() {
          trList.add(ListTr(
            TrNo: c['TRNo'].toString(),
            TrDate: c['TrDate'].toString(),
            Amount: c['TrAmount'].toString(),
            CCode: c['Code'].toString(),
            CName: c['CName'].toString(),
            Ctype: c['Chick_type'].toString(),
            bankdet: c['Bank_det'].toString(),
            hatchdate: c['HatchDate'].toString(),
            paytype: c['Pay_mode'].toString(),
            rate: c['Rate'].toString(),
            bankdate: c['bankdate'].toString()
          ));
        });
      }
    }
    _isDropDownFilled = true;
    // print(trList[0].CName);
  }

  _selectTrDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _trDateController.text = selectedDate.toString().split(' ')[0];
      });
    } else {
      _trDateController.text = selectedDate.toString().split(' ')[0];
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    // fillTrData();
    fillAllTrData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List TR'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Hello: $UserName   Area:$AreaName',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              height: 3,
              thickness: 1,
              color: Color(0xFFDCE7F1),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  flex: 6,
                  child: TextField(
                    controller: _trDateController,
                    style: TextStyle(fontSize: 16),
                    decoration: kTextFieldDecoration.copyWith(
                        labelText: 'Select Hatch Date'),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () {
                      _selectTrDate(context);
                    },
                  ),
                )
              ],
            ),
            RoundedButton(
                title: 'Show TR',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  fillTrData();
                }),
            RoundedButton(
                title: 'Show ALL TR',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  fillAllTrData();
                }),
            !_isDropDownFilled
                ? SizedBox(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
            : Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: ListView.builder(
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, PdfTr.id , arguments: {
                        'trno':trList[index].TrNo.toString(),
                        'trdate': trList[index].TrDate.toString(),
                        'cname':trList[index].CName! +"#" + trList[index].CCode.toString(),
                        'amt':trList[index].Amount.toString(),
                        'bankdet': trList[index].bankdet.toString(),
                        'hatchdate':trList[index].hatchdate.toString(),
                        'rate':trList[index].rate.toString(),
                      });
                      print('tr pds');
                    },
                    child: _ListCard(
                      number: trList[index].TrNo,
                      title: '${trList[index].CName} · ${trList[index].CCode}',
                      trailing: '₹${_fmtIndian(_toNum(trList[index].Amount))}',
                      details: [
                        MapEntry('TR date', trList[index].TrDate),
                        MapEntry('Rate', trList[index].rate),
                        MapEntry('Chick', trList[index].Ctype),
                        MapEntry('Hatch', trList[index].hatchdate),
                        MapEntry('Bank', trList[index].bankdet),
                        MapEntry('Deposit', trList[index].bankdate),
                      ],
                    ),
                  ),
                  itemCount: trList.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


// ---------------------------------------------------------------------------
// Self-contained card + formatting for this list (no other files needed).
// The number shortens with "…" and the amount scales down, so nothing is
// pushed off the right edge.
// ---------------------------------------------------------------------------

double _toNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '').trim()) ?? 0;
}

/// Indian digit grouping: 1234567.5 -> "12,34,568".
String _fmtIndian(double v) {
  final neg = v < 0;
  var s = v.abs().round().toString();
  if (s.length > 3) {
    final last3 = s.substring(s.length - 3);
    var rest = s.substring(0, s.length - 3);
    final parts = <String>[];
    while (rest.length > 2) {
      parts.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) parts.insert(0, rest);
    s = '${parts.join(',')},$last3';
  }
  return '${neg ? '-' : ''}$s';
}

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.number,
    required this.title,
    this.trailing,
    this.details = const [],
  });

  final String? number;
  final String title;
  final String? trailing;
  final List<MapEntry<String, String?>> details;

  static const _primary = Color(0xFF0878C0);
  static const _danger = Color(0xFFDC2626);
  static const _text = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF6B7280);
  static const _border = Color(0xFFDCE7F1);

  @override
  Widget build(BuildContext context) {
    final n = number?.trim() ?? '';
    final hasNo = n.isNotEmpty && n != 'null' && n != '-';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasNo
                        ? _primary.withOpacity(0.08)
                        : _danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasNo ? n : 'No number',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: hasNo ? _primary : _danger,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (trailing != null)
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        trailing!,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _text),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: _text)),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: details
                  .where((d) =>
                      d.value != null && d.value!.isNotEmpty && d.value != 'null')
                  .map((d) => Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '${d.key} ',
                            style:
                                const TextStyle(fontSize: 12.5, color: _muted)),
                        TextSpan(
                            text: d.value,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: _text)),
                      ])))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
