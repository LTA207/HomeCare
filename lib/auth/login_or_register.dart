import 'package:flutter/material.dart';
import 'package:foodapp/pages/login_page.dart';
import 'package:foodapp/pages/register_page.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/data/model/service.dart';

class LoginOrRegister extends StatefulWidget {
  final String deviceToken;

  const LoginOrRegister({
    super.key,
    required this.deviceToken,
  });

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // Initially show the login page
  bool showLoginPage = true;

  // Toggle between login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginPage
          ? LoginPage(
              key: const ValueKey('LoginPage'),
              onTap: togglePages,
              deviceToken: widget.deviceToken,
            )
          : RegisterPage(
              key: const ValueKey('RegisterPage'),
              onTap: togglePages,
            ),
    );
  }
}
