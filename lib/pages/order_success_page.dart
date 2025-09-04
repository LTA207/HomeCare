import 'package:flutter/material.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/pages/home_page.dart';
import 'dart:math' as math;

class OrderSuccess extends StatefulWidget {
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final dynamic mainMessage;
  final dynamic subMessage;
  final String token;
  final String refreshToken;

  const OrderSuccess({
    super.key,
    required this.customer,
    required this.costFactors,
    required this.services,
    this.mainMessage,
    this.subMessage, required this.token, required this.refreshToken,
  });

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess>
    with SingleTickerProviderStateMixin {
  // Initialize controllers with default values
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );

  // Initialize animations
  late final Animation<double> _scaleAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ),
  );

  late final Animation<double> _rotateAnimation = Tween<double>(
    begin: 0,
    end: 2 * math.pi,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ),
  );

  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    ),
  );

  @override
  void initState() {
    super.initState();
    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[50]!,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                spreadRadius: 4,
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            size: 120,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        widget.mainMessage ?? "Thanh toán thành công!",
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.subMessage ??
                              "Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi. Hi vọng được phục vụ bạn nhiều hơn.",
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      HomePage(
                                customer: widget.customer,
                                costFactor: widget.costFactors,
                                services: widget.services,
                                        token: widget.token,
                                        refreshToken: widget.refreshToken,
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "Về Trang Chủ",
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
