import 'package:flutter/material.dart';
import '../models/menu.dart';

// Dashboard icon colours, all taken from the Phoenix logo blues.
const _indigo = Color(0xFF0878C0);
const _teal = Color(0xFF00477F);
const _amber = Color(0xFF2E9BD6);
const _rose = Color(0xFF00477F);
const _violet = Color(0xFF2E9BD6);
const _sky = Color(0xFF0878C0);
const _slate = Color(0xFF3A3A3A);
const _green = Color(0xFF0878C0);

// "Image Upload" was removed from the menu: its route is commented out in
// main.dart, so tapping it crashed the app. Re-add it here once the route
// is registered again.
const DUMMY_CATEGORIES = const [
  // ---- New entries ----
  Menu(
      id: 'c1',
      title: 'TR Creation',
      subtitle: 'Record a payment',
      color: _indigo,
      routeName: 'TrEntry',
      icon: Icons.note_add_outlined),
  Menu(
      id: 'c2',
      title: 'Supply',
      subtitle: 'Create a DM',
      color: _teal,
      icon: Icons.local_shipping_outlined,
      routeName: 'SupplyEntryScreen'),
  Menu(
      id: 'c3',
      title: 'Chicks Demand',
      subtitle: 'Book a demand',
      color: _amber,
      routeName: 'ChicksDemandScreen',
      icon: Icons.egg_outlined),
  Menu(
      id: 'c11',
      title: 'New Farmer',
      subtitle: 'Add a customer',
      routeName: 'NewCustomeradd',
      color: _violet,
      icon: Icons.person_add_alt_1_outlined),
  Menu(
      id: 'c13',
      title: 'Daily Expenses',
      subtitle: 'Log an expense',
      color: _rose,
      routeName: 'DailyExpensesScreen',
      icon: Icons.account_balance_wallet_outlined),
  Menu(
      id: 'c10',
      title: 'Start Trip',
      subtitle: 'Track a visit',
      routeName: 'TripScreen',
      color: _sky,
      icon: Icons.directions_car_outlined),
  Menu(
      id: 'c14',
      title: 'LR (Other)',
      subtitle: 'Other company',
      routeName: 'LayerScreen',
      color: _slate,
      icon: Icons.business_outlined),

  // ---- Reports ----
  Menu(
      id: 'c6',
      title: 'TR List',
      subtitle: 'By date',
      color: _indigo,
      icon: Icons.receipt_long_outlined,
      routeName: 'ListTrData',
      section: 'reports'),
  Menu(
      id: 'c4',
      title: 'TR by Customer',
      subtitle: 'Customer-wise',
      routeName: 'ListTrCustomer',
      color: _indigo,
      icon: Icons.person_search_outlined,
      section: 'reports'),
  Menu(
      id: 'c7',
      title: 'Supply List',
      subtitle: 'By date',
      color: _teal,
      icon: Icons.inventory_2_outlined,
      routeName: 'ListDmData',
      section: 'reports'),
  Menu(
      id: 'c15',
      title: 'Supply by Customer',
      subtitle: 'Customer-wise',
      color: _teal,
      routeName: 'ListDmCustomer',
      icon: Icons.manage_search_outlined,
      section: 'reports'),
  Menu(
      id: 'c8',
      title: 'Demand List',
      subtitle: 'All demands',
      color: _amber,
      icon: Icons.list_alt_outlined,
      routeName: 'ListDemadData',
      section: 'reports'),
  Menu(
      id: 'c9',
      title: 'Expense List',
      subtitle: 'All expenses',
      color: _rose,
      routeName: 'ListExpenseData',
      icon: Icons.payments_outlined,
      section: 'reports'),
  Menu(
      id: 'c12',
      title: 'New Farmers',
      subtitle: 'Recently added',
      routeName: 'ListNewFarmer',
      color: _green,
      icon: Icons.groups_outlined,
      section: 'reports'),
];
