import 'package:flutter/material.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/pages/services_order.dart';

class AllServicesPage extends StatelessWidget {
  final dynamic customer;
  final List<Services> services;
  final List<CostFactor> costFactors;
  final String token;
  final String refreshToken;

  const AllServicesPage({
    Key? key,
    required this.customer,
    required this.services,
    required this.costFactors, required this.token, required this.refreshToken,
  }) : super(key: key);

  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Dịch vụ chăm sóc và hỗ trợ',
      'services': [
        {
          'iconPath': 'lib/images/services/clean.png',
          'label': 'Chăm sóc 10 tuổi',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/rubbish.png',
          'label': 'Chăm sóc người bệnh',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/rubbish.png',
          'label': 'Chăm sóc người bệnh',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/rubbish.png',
          'label': 'Chăm sóc người bệnh',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/rubbish.png',
          'label': 'Chăm sóc người bệnh',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/rubbish.png',
          'label': 'Chăm sóc người bệnh',
          'isNew': false,
        },
      ]
    },
    {
      'title': 'Dịch vụ bảo dưỡng điện máy',
      'services': [
        {
          'iconPath': 'lib/images/services/wash.png',
          'label': 'Vệ sinh bình nóng lạnh',
          'isNew': true,
        },
        {
          'iconPath': 'lib/images/services/clean.png',
          'label': 'Vệ sinh máy giặt',
          'isNew': true,
        },
      ]
    },
    {
      'title': 'Dịch vụ dành cho doanh nghiệp',
      'services': [
        {
          'iconPath': 'lib/images/services/xit.png',
          'label': 'Dọn dẹp văn phòng',
          'isNew': true,
        },
        {
          'iconPath': 'lib/images/services/wash.png',
          'label': 'Dọn dẹp phòng',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/nobiet.png',
          'label': 'Vệ sinh phòng',
          'isNew': true,
        },
        {
          'iconPath': 'lib/images/services/nobiet.png',
          'label': 'Vệ sinh phòng',
          'isNew': true,
        },
      ]
    },
    {
      'title': 'Dịch vụ tiện ích nâng cao',
      'services': [
        {
          'iconPath': 'lib/images/services/xabong.png',
          'label': 'Giặt ủi',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/xit.png',
          'label': 'Nấu ăn gia đình',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/bridge.png',
          'label': 'Đi Chợ',
          'isNew': false,
        },
        {
          'iconPath': 'lib/images/services/clean.png',
          'label': 'Khử khuẩn',
          'isNew': false,
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Khám phá HomeCare',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: categories.map((category) {
            return _buildCategorySection(context, category);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề danh mục
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              category['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Quicksand',
                color: Colors.black87,
              ),
            ),
          ),
          // Lưới dịch vụ
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: category['services'].map<Widget>((service) {
              return _buildServiceItem(context, service);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, Map<String, dynamic> service) {
    return InkWell(
      onTap: () => _navigateToService(context),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildServiceIcon(service['iconPath'], service['isNew']),
          const SizedBox(height: 6),
          _buildServiceLabel(service['label']),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(String iconPath, bool isNew) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(
            iconPath,
            height: 40,
            width: 40,
            fit: BoxFit.contain,
          ),
        ),
        if (isNew)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceLabel(String label) {
    return Flexible(
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _navigateToService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesOrder(
          customer: customer,
          service: services[0],
          costFactors: costFactors,
          services: services,
          token: token,
          refreshToken: refreshToken,
        ),
      ),
    );
  }
}
