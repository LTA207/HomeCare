import 'package:flutter/material.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/data/repository/repository.dart';
import 'package:foodapp/pages/home_page.dart';
import 'package:foodapp/components/review_dialog.dart';
import 'dart:math' as math;

import '../data/model/requestdetail.dart';

class OrderSuccess extends StatefulWidget {
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final dynamic mainMessage;
  final dynamic subMessage;
  final String token;
  final String refreshToken;
  final List<RequestDetail> requestDetails;
  final String deviceToken;

  const OrderSuccess({
    super.key,
    required this.customer,
    required this.costFactors,
    required this.services,
    this.mainMessage,
    this.subMessage,
    required this.token,
    required this.refreshToken,
    required this.requestDetails,
    required this.deviceToken,
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

  bool _hasReviewed = false; // Thêm flag để theo dõi trạng thái đánh giá

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

  void _showReviewDialog() {
    String? requestId = widget.requestDetails.isNotEmpty
        ? widget.requestDetails.first.id
        : null;

    ReviewDialog.show(
      context: context,
      requestId: requestId,
      token: widget.token,
      onReviewSubmitted: () {
        setState(() {
          _hasReviewed = true;
        });
        _navigateToHome();
      },
      onSkipped: () {
        setState(() {
          _hasReviewed = true;
        });
        _navigateToHome();
      },
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(
          customer: widget.customer,
          costFactor: widget.costFactors,
          services: widget.services,
          token: widget.token,
          refreshToken: widget.refreshToken,
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
                                color: Colors.green.withValues(alpha: 0.3),
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
                        onPressed: _hasReviewed ? _navigateToHome : _showReviewDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          _hasReviewed ? "Về Trang Chủ" : "Đánh Giá & Về Trang Chủ",
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
