class LayerModel {

  int? id;
  String? areaCode;
  String? area;
  String? session;
  String? uname;
  String? code;
  String? cname;
  String? chickType;
  String? chicksCompany;
  String? remarks;

  double? age;
  double? flockNo;
  double? totalChicks;

  int? dmidarea;

  String? hatchDate;
  String? entrydate;

  LayerModel({
    this.id,
    this.areaCode,
    this.area,
    this.session,
    this.uname,
    this.code,
    this.cname,
    this.chickType,
    this.chicksCompany,
    this.remarks,
    this.age,
    this.flockNo,
    this.totalChicks,
    this.dmidarea,
    this.hatchDate,
    this.entrydate
  });

  Map<String,dynamic> toJson(){
    return{
      "AreaCode":areaCode,
      "Area":area,
      "session":session,
      "uname":uname,
      "Code":code,
      "CName":cname,
      "Chick_type":chickType,
      "ChicksComapmy":chicksCompany,
      "Remarks":remarks,
      "Age":age,
      "Flock_No":flockNo,
      "TotalChicks":totalChicks,
      "dmidarea":dmidarea,
      "HatchDate":hatchDate,
      "entrydate":entrydate
    };
  }
}