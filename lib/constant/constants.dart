import 'package:flutter/material.dart';

 String? UserName="";
 String? UserType="";
 String? AreaCode="";
 String? AreaName="";
 final String Url= "http://137.97.174.50:91/mynew.asmx/";

const String Url1= "http://137.97.174.50:3002/api";

const String Url2= "137.97.174.50:3002";

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: 'Type your message here...',
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

// Inherits everything (border, fill, padding) from AppTheme's
// inputDecorationTheme, so all screens using it get the modern style.
const kTextFieldDecoration = InputDecoration();


const List<Color> signInGradients = [
  Color(0xFF0EDED2),
  Color(0xFF03A0FE),
];

const List<Color> signUpGradients = [
  Color(0xFFFF9945),
  Color(0xFFFc6076),
];