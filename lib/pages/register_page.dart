import 'package:flutter/material.dart';
import 'package:foodapp/components/my_button.dart';
import 'package:foodapp/components/my_textfield.dart';
import 'package:foodapp/components/warning_dialog.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/providers/auth_provider.dart';
import 'package:lottie/lottie.dart';

import '../components/city_selected.dart';
import '../components/spashscreen.dart';
import '../data/model/location.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Location? selectedProvince;
  String? selectedWard;
  String? selectedDetailedAddress;

  @override
  void initState() {
    super.initState();

    // Load registration data using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadRegistrationData();
    });
  }

  Future<void> validateAndRegister() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmController.text.trim(),
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      selectedProvince: selectedProvince,
      selectedWard: selectedWard,
      selectedDetailedAddress: selectedDetailedAddress,
    );

    if (success && mounted) {
      showPopUpWarning(context, 'Đăng ký thành công. Vui lòng đăng nhập để tiếp tục');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SplashScreen(deviceToken: '',),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else if (authProvider.generalError != null && mounted) {
      showPopUpWarning(context, authProvider.generalError!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading && authProvider.locations.isEmpty) {
            return Center(
              child: Lottie.asset(
                'lib/images/loading.json',
                width: 100,
                height: 100,
                repeat: true,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Image.asset('lib/images/logo.png', width: 180, height: 180),
                const SizedBox(height: 20),

                MyTextField(
                  controller: fullNameController,
                  hintText: "Nhập tên của bạn",
                  errorText: authProvider.fullNameError,
                  onChanged: (value) {
                    if (authProvider.fullNameError != null) {
                      authProvider.clearFieldError('fullName');
                    }
                  },
                ),
                const SizedBox(height: 15),

                MyTextField(
                  controller: phoneController,
                  hintText: "Nhập số điện thoại",
                  keyboardType: TextInputType.number,
                  errorText: authProvider.phoneError,
                  onChanged: (value) {
                    if (authProvider.phoneError != null) {
                      authProvider.clearFieldError('phone');
                    }
                  },
                ),
                const SizedBox(height: 15),

                MyTextField(
                  controller: emailController,
                  hintText: "Nhập email",
                  keyboardType: TextInputType.emailAddress,
                  errorText: authProvider.emailError,
                  onChanged: (value) {
                    if (authProvider.emailError != null) {
                      authProvider.clearFieldError('email');
                    }
                  },
                ),
                const SizedBox(height: 15),

                SelectLocation(
                  locations: authProvider.locations,
                  onProvinceSelected: (province) {
                    setState(() {
                      selectedProvince = province;
                    });
                    if (authProvider.addressError != null) {
                      authProvider.clearFieldError('address');
                    }
                  },
                  onWardSelected: (ward) {
                    setState(() {
                      selectedWard = ward;
                    });
                    if (authProvider.addressError != null) {
                      authProvider.clearFieldError('address');
                    }
                  },
                  onAddressChanged: (detailedAddress) {
                    setState(() {
                      selectedDetailedAddress = detailedAddress;
                    });
                    if (authProvider.addressError != null) {
                      authProvider.clearFieldError('address');
                    }
                  },
                ),

                if (authProvider.addressError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          authProvider.addressError!,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 15),

                MyTextField(
                  controller: passwordController,
                  hintText: "Nhập mật khẩu",
                  obscureText: true,
                  errorText: authProvider.passwordError,
                  onChanged: (value) {
                    if (authProvider.passwordError != null) {
                      authProvider.clearFieldError('password');
                    }
                  },
                ),
                const SizedBox(height: 15),

                MyTextField(
                  controller: confirmController,
                  hintText: "Xác nhận mật khẩu",
                  obscureText: true,
                  errorText: authProvider.confirmError,
                  onChanged: (value) {
                    if (authProvider.confirmError != null) {
                      authProvider.clearFieldError('confirm');
                    }
                  },
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

                const SizedBox(height: 25),

                MyButton(
                  text: authProvider.isLoading ? "Đang đăng ký..." : "Đăng ký",
                  onTap: authProvider.isLoading ? null : validateAndRegister,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
