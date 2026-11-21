import 'package:flutter/material.dart';

import '../constant/constants.dart';
import '../network/network.dart';
import '../screen/menu_sales_screen.dart';
import '../services/doc_number_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

/// Login form card. Used by MyLoginScreen.
class LoginUI extends StatefulWidget {
  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final _userNameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userNameTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final user = _userNameTextController.text.trim();
    final pass = _passwordTextController.text;

    if (user.isEmpty) {
      showAppSnack(context, 'Please enter your user name');
      return;
    }
    if (pass.isEmpty) {
      showAppSnack(context, 'Please enter your password');
      return;
    }
    if (!await hasInternet()) {
      if (mounted) showAppSnack(context, 'Please check your internet connection');
      return;
    }

    setState(() => _loading = true);
    try {
      // Encoded properly — a password containing & or # used to break login.
      final url = Uri.parse('http://137.97.174.50:91/mynew.asmx/Login_new')
          .replace(queryParameters: {'User': user, 'Password': pass});
      final data = await NetworkHelper(url).getData();
      final rows = data['Login'];

      // Check BEFORE reading [0] — the old code read first and crashed on
      // wrong credentials instead of showing the message.
      if (rows is! List || rows.isEmpty) {
        if (mounted) showAppSnack(context, 'Invalid username or password');
        return;
      }

      final u = rows[0];
      UserName = u['UserName']?.toString();
      UserType = u['UserType']?.toString();
      AreaCode = u['AreaCode']?.toString();
      AreaName = u['AreaName']?.toString();

      if (!mounted) return;
      if (UserType == 'Sales') {
        Navigator.pushNamedAndRemoveUntil(
            context, SalesMenuGrid.id, (route) => false);
      } else {
        showAppSnack(context, 'This app is for Sales users only');
      }
    } catch (e) {
      print('Login failed: $e');
      if (mounted) showAppSnack(context, 'Could not reach the server. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Sign in',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Use your Phoenix sales account',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 22),
          TextField(
            controller: _userNameTextController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordTextController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white))
                : const Text('Log in'),
          ),
        ],
      ),
    );
  }
}
