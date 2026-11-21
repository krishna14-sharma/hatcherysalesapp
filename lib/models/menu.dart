import 'package:flutter/material.dart';

class Menu {
  final String id;
  final String title;
  final Color color;
  final String? routeName;
  final IconData? icon;

  /// Dashboard grouping: 'entry' or 'reports'.
  final String section;
  final String? subtitle;

  const Menu({
    required this.id,
    required this.title,
    this.color = Colors.blueGrey,
    this.routeName,
    this.icon,
    this.section = 'entry',
    this.subtitle,
  });
}
