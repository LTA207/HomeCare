import 'package:flutter/material.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/pages/all_service_page.dart';
import 'package:foodapp/pages/services_order.dart';
import '../data/model/service.dart';

class ServiceListMenu extends StatefulWidget {
  final dynamic customer;
  final List<Services> services;
  final List<CostFactor> costFactors;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const ServiceListMenu({
    Key? key,
    required this.customer,
    required this.services,
    required this.costFactors,
    required this.token,
    required this.refreshToken,
    required this.deviceToken,
  }) : super(key: key);

  @override
  State<ServiceListMenu> createState() => _ServiceListMenuState();
}

class _ServiceListMenuState extends State<ServiceListMenu> {
  final servicesInfo = <Map<String, dynamic>>[
    {'icon': Icons.cleaning_services, 'label': 'Dọn nhà'},
    {'icon': Icons.child_care, 'label': 'Chăm sóc bé'},
    {'icon': Icons.elderly, 'label': 'Chăm sóc người già'},
    {'icon': Icons.pregnant_woman, 'label': 'Chăm sóc sản phụ'},
    {'icon': Icons.medical_services, 'label': 'Nuôi bệnh'},
    {'icon': Icons.school, 'label': 'Đưa đón bé'},
    {'icon': Icons.restaurant, 'label': 'Nấu ăn'},
    {'icon': Icons.cleaning_services_outlined, 'label': 'Vệ sinh phòng'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Tiêu đề + Xem tất cả

          Text(
            'Danh sách dịch vụ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Quicksand',
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 16,
            runSpacing: 20,
            alignment: WrapAlignment.start,
            children: List.generate(
              servicesInfo.length,
              (index) => _buildServiceItem(index),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllServicesPage(
                        customer: widget.customer,
                        services: widget.services,
                        costFactors: widget.costFactors,
                        token: widget.token,
                        refreshToken: widget.refreshToken,
                        deviceToken: widget.deviceToken),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(int index) {
    return InkWell(
      onTap: () => _navigateToService(index),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              servicesInfo[index]['icon'] as IconData,
              color: Colors.green.shade700,
              size: 32, // Tăng icon size
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 70,
            child: Text(
              servicesInfo[index]['label'],
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToService(int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ServicesOrder(
          customer: widget.customer,
          service: widget.services[index],
          costFactors: widget.costFactors,
          services: widget.services,
          token: widget.token,
          refreshToken: widget.refreshToken,
          deviceToken: widget.deviceToken,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
