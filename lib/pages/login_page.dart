import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/components/my_button.dart';
import 'package:foodapp/components/my_textfield.dart';
import 'package:foodapp/pages/home_page.dart';
import 'package:foodapp/pages/register_page.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  final String deviceToken;

  const LoginPage({
    super.key,
    this.onTap, required this.deviceToken,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    setupAnimations();
    setupFocusListeners();

    // Load initial data using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadInitialData();
    });
  }

  void setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));

    _animationController.forward();
  }

  void setupFocusListeners() {
    phoneFocusNode.addListener(() {
      setState(() {});
    });
    passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  Future<void> login() async {
    final authProvider = context.read<AuthProvider>();

    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    final success = await authProvider.login(phone, password, widget.deviceToken);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(
            customer: authProvider.customer,
            requests: authProvider.requestsCustomer,
            services: authProvider.services,
            token: authProvider.token,
            refreshToken: authProvider.refreshToken,
            deviceToken: widget.deviceToken,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 30.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo with hero animation
                            Hero(
                              tag: 'app_logo',
                              child: Image.asset(
                                'lib/images/logo.png',
                                width: 180,
                                height: 180,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Welcome text
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0, end: 1),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: Column(
                                children: const [
                                  Text(
                                    "Chào mừng trở lại!",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Hãy đăng nhập để tiếp tục",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Phone input
                            MyTextField(
                              controller: phoneController,
                              hintText: "Số điện thoại",
                              obscureText: false,
                              keyboardType: TextInputType.number,
                              errorText: authProvider.phoneError,
                              focusNode: phoneFocusNode,
                              onChanged: (value) {
                                if (authProvider.phoneError != null) {
                                  authProvider.clearFieldError('phone');
                                }
                              },
                            ),

                            const SizedBox(height: 15),

                            // Password input
                            MyTextField(
                              controller: passwordController,
                              hintText: "Mật khẩu",
                              obscureText: true,
                              keyboardType: TextInputType.text,
                              errorText: authProvider.passwordError,
                              focusNode: passwordFocusNode,
                              onChanged: (value) {
                                if (authProvider.passwordError != null) {
                                  authProvider.clearFieldError('password');
                                }
                              },
                            ),

                            const SizedBox(height: 25),

                            // Login button
                            MyButton(
                              text: authProvider.isLoading ? "Đang đăng nhập..." : "Đăng nhập",
                              onTap: authProvider.isLoading ? null : login,
                            ),

                            // Show general error if exists
                            if (authProvider.generalError != null) ...[
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.generalError!,
                                        style: TextStyle(
                                          color: Colors.red.shade600,
                                          fontSize: 14,
                                          fontFamily: 'Quicksand',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Divider
                            Row(
                              children: const [
                                Expanded(
                                    child:
                                        Divider(thickness: 1, color: Colors.grey)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "Hoặc",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child:
                                        Divider(thickness: 1, color: Colors.grey)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Register link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Chưa có tài khoản?",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterPage(),
                                    ),
                                  ),
                                  child: const Text(
                                    " Đăng ký",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
