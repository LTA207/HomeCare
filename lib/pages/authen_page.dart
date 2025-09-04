import 'package:flutter/material.dart';
import 'package:foodapp/components/my_button.dart';
import 'package:foodapp/components/my_confirm_text.dart';
import 'package:foodapp/components/spashscreen.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/repository/repository.dart';
import 'package:foodapp/pages/login_page.dart';

import '../data/model/location.dart';

class AuthenticationPage extends StatefulWidget {
  final void Function()? onTap;
  final Customer customer;

  const AuthenticationPage(
      {super.key,
      required this.onTap, required this.customer,});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String verificationCode = ""; // Biến lưu mã xác nhận

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void login() async{

    if (verificationCode.length == 6 &&
        verificationCode.compareTo('111111') == 0) {
      // Thực hiện xác thực ở đây (gửi mã lên server để kiểm tra)
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Hiển thị cảnh báo nếu chưa nhập đủ mã
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ mã xác nhận")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade50,
                  Colors.white,
                  Colors.green.shade50,
                ],
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'lib/images/logo.png',
                            width: 180,
                            height: 180,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Mã xác nhận gồm 6 chữ số vừa được gửi vào email của bạn. Vui lòng nhập mã của bạn bên dưới:',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            height: 1.5,
                            color: Color(0xFF2D3748),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Nhận giá trị mã xác nhận
                      MyConfirmText(
                        onCodeChanged: (code) {
                          setState(() {
                            verificationCode = code;
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // Nút xác nhận
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Xác nhận",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative circles
class CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        colors: [
          Colors.green.shade200.withOpacity(0.2),
          Colors.green.shade300.withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Top-left circles
    canvas.drawCircle(
      Offset(0, size.height * 0.1),
      size.width * 0.2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.1, 0),
      size.width * 0.15,
      paint,
    );

    // Bottom-right circles
    canvas.drawCircle(
      Offset(size.width, size.height * 0.9),
      size.width * 0.2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height),
      size.width * 0.15,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
