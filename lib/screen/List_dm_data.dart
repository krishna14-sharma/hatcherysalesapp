import 'package:flutter/material.dart';
import '../network/network.dart';
import '../constant/constants.dart';
import '../widgets/rounded_button.dart';
import '../screen/Pdf_dm.dart';

class ListDm {
  final String? dmNo;
  final String? dmDate;
  final String? totalChicks;
  final String? CCode;
  final String? CName;
  final String? Ctype;
  final String? mortalty;
  final String? rate;
  final String? hdate;
  final String? hatchries;

  ListDm(
      {this.dmNo,
      this.dmDate,
      this.totalChicks,
      this.CCode,
      this.CName,
      this.Ctype,
      this.mortalty,
      this.rate,
      this.hdate,
      this.hatchries});
}

class ListDmData extends StatefulWidget {
  static const String id = 'ListDmData';
  @override
  _ListDmDataState createState() => _ListDmDataState();
}

class _ListDmDataState extends State<ListDmData> {
  final _dmDateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<ListDm> dmList = [];
  bool _isDropDownFilled = false;

  void filldmData() async {
    Uri url =
       Uri.parse('$Url/ShowDMData?AreaCode=$AreaCode&uname=$UserName&DMDate=${_dmDateController.text}');
    print(url);
    NetworkHelper networkHelper = NetworkHelper(url);
    var data = await networkHelper.getData();
   // print(data);
    dmList.clear();
    for (var c in data['DMData']) {
      if (c['DMNo'].toString() != 'null') {
        setState(() {
          dmList.add(ListDm(
            dmNo: c['DMNo'].toString(),
            dmDate: c['DMDate'].toString(),
            totalChicks: c['TotalChicks'].toString(),
            CCode: c['Code'].toString(),
            CName: c['CName'].toString(),
            Ctype: c['Chick_type'].toString(),
            mortalty: c['Mortality'].toString(),
            rate: c['Rate'].toString(),
            hdate: c['HatchDate'].toString(),
            hatchries: c['Hatchries'].toString()
          ));
        });
      }
    }
    _isDropDownFilled = true;
    print(dmList[0].CName);
  }

  void fillAlldmData() async {
    Uri url =  Uri.parse('$Url/ShowAllDMData?AreaCode=$AreaCode&uname=$UserName');
    print(url);
    NetworkHelper networkHelper = NetworkHelper(url);
    var data = await networkHelper.getData();
    //print(data);
    dmList.clear();
    for (var c in data['DMData']) {
      if (c['DMNo'].toString() != 'null') {
        setState(() {
          dmList.add(ListDm(
            dmNo: c['DMNo'].toString(),
            dmDate: c['DMDate'].toString(),
            totalChicks: c['TotalChicks'].toString(),
            CCode: c['Code'].toString(),
            CName: c['CName'].toString(),
            Ctype: c['Chick_type'].toString(),
            mortalty: c['Mortality'].toString(),
            rate: c['Rate'].toString(),
            hdate: c['HatchDate'].toString(),
            hatchries: c['Hatchries'].toString()
          ));
        });
      }
    }
    _isDropDownFilled = true;
    print(dmList[0].CName);
  }

  _selectTrDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dmDateController.text = selectedDate.toString().split(' ')[0];
      });
    } else {
      _dmDateController.text = selectedDate.toString().split(' ')[0];
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
     fillAlldmData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Supply'),
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
                    controller: _dmDateController,
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
                title: 'Show Supply',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  filldmData();
                }),
            RoundedButton(
                title: 'Show All Supply',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  fillAlldmData();
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
                            Navigator.pushNamed(context, PdfDm.id , arguments: {
                              'dmno':dmList[index].dmNo.toString(),
                              'dmdate': dmList[index].dmDate.toString(),
                              'cname':dmList[index].CName! +"#" + dmList[index].CCode.toString(),
                              'hatchdate':dmList[index].hdate.toString(),
                              'ctype': dmList[index].Ctype .toString(),
                              'qty':dmList[index].totalChicks.toString(),
                              'mortality':dmList[index].mortalty.toString(),
                             'rate':dmList[index].rate.toString(),
                            });
                            print('tr pds');

                          },
                          child: _ListCard(
                            number: dmList[index].dmNo,
                            title: '${dmList[index].CName} · ${dmList[index].CCode}',
                            trailing: '${_fmtIndian(_toNum(dmList[index].totalChicks))} Chicks',
                            details: [
                              MapEntry('DM date', dmList[index].dmDate),
                              MapEntry('Chick', dmList[index].Ctype),
                              MapEntry('Hatch', dmList[index].hdate),
                              MapEntry('Mortality', dmList[index].mortalty),
                              MapEntry('Rate', dmList[index].rate),
                              MapEntry('Unit', dmList[index].hatchries),
                            ],
                          ),
                        ),
                        itemCount: dmList.length,
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
