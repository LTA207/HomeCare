import 'dart:async';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/components/feature_helper_list.dart';
import 'package:foodapp/components/service_list_menu.dart';
import 'package:foodapp/pages/activity_page.dart';
import 'package:foodapp/pages/all_reward_page.dart';
import 'package:foodapp/pages/all_service_page.dart';
import 'package:foodapp/pages/choose_location_page.dart';
import 'package:foodapp/pages/notification_page.dart';
import 'package:foodapp/pages/profile_page.dart';
import 'package:foodapp/pages/services_order.dart';
import 'package:foodapp/pages/wallet_page.dart';
import '../../data/model/customer.dart';
import '../data/model/request.dart';
import '../data/model/service.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class HomePage extends StatefulWidget {
  final dynamic customer;
  final List<Services> services;
  final List<Requests>? requests;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const HomePage({
    super.key,
    this.customer,
    required this.services,
    this.requests,
    required this.token,
    required this.refreshToken,
    required this.deviceToken,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [];
  bool _isHidden = true;

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomeContent(
        customer: widget.customer,
        services: widget.services,
        token: widget.token,
        refreshToken: widget.refreshToken,
        deviceToken: widget.deviceToken,
      ),
      ActivityPage(
        customer: widget.customer,
        services: widget.services,
        token: widget.token,
        refreshToken: widget.refreshToken,
        deviceToken: widget.deviceToken,
      ),
      NotificationPage(),
      ProfilePage(
        customer: widget.customer,
        token: widget.token,
        refreshToken: widget.refreshToken,
        deviceToken: widget.deviceToken,
      ),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex.clamp(0, _pages.length - 1)],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SalomonBottomBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          curve: Curves.easeInOut,
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              title: const Text("Trang chủ"),
              selectedColor: Colors.green,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.calendar_month_rounded),
              title: const Text("Hoạt động"),
              selectedColor: Colors.blue,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.notifications_rounded),
              title: const Text("Thông báo"),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_rounded),
              title: const Text("Cá nhân"),
              selectedColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final Customer customer;
  final List<Services> services;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const HomeContent({
    super.key,
    required this.customer,
    required this.services,
    required this.token,
    required this.refreshToken,
    required this.deviceToken,
  });

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = true;
  int _currentBannerPage = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _startBannerTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerPage = (_currentBannerPage + 1) % bannerImages.length;
        _bannerController.animateToPage(
          _currentBannerPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  List<String> bannerImages = [
    'lib/images/banner_1.png',
    'lib/images/banner_2.png',
    'lib/images/banner_3.png',
  ];

  Future<void> _handleRefresh() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Update any necessary data here
    });
  }

  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              color: Colors.green,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Custom Header
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),

                  // Main Content
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 16),
                        _buildQuickActions(),
                        const SizedBox(height: 20),
                        _buildBannerSection(),
                        // const SizedBox(height: 24),
                        // _buildServicesSection(),
                        const SizedBox(height: 24),
                        // _buildServiceList(),
                        _buildServicesSection(),
                        const SizedBox(height: 24),
                        _buildRewardSection(context),
                        const SizedBox(height: 24),
                        _buildPromotionSection(context),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceList() {
    final actions = [
      {'icon': Icons.cleaning_services_rounded, 'label': 'Dọn dẹp'},
      {'icon': Icons.local_laundry_service_rounded, 'label': 'Giặt ủi'},
      {'icon': Icons.build_rounded, 'label': 'Sửa chữa'},
      {'icon': Icons.restaurant_rounded, 'label': 'Nấu ăn'},
      {'icon': Icons.restaurant_rounded, 'label': 'Nấu ăn'},
      {'icon': Icons.restaurant_rounded, 'label': 'Nấu ăn'},
      {'icon': Icons.restaurant_rounded, 'label': 'Nấu ăn'},
      {'icon': Icons.restaurant_rounded, 'label': 'Nấu ăn'},
    ];

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
        children: [
          Row(
            children: [
              Text(
                'Dịch vụ nổi bật',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Quicksand'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllServicesPage(
                        services: widget.services,
                        customer: widget.customer,
                        token: widget.token,
                        refreshToken: widget.refreshToken,
                        deviceToken: widget.deviceToken,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
          Wrap(
            spacing: 30,
            runSpacing: 20,
            alignment: WrapAlignment.start,
            children: actions.map((action) {
              return InkWell(
                onTap: () {
                  // Handle action tap
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: Colors.green.shade700,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? 'Chào buổi sáng'
        : hour < 18
            ? 'Chào buổi chiều'
            : 'Chào buổi tối';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.green,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row with Greeting and Actions
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        // Gọi hàm đổi ngôn ngữ ở đây
                        print('Đổi sang ngôn ngữ: $value');
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'vi',
                          child: Text('🇻🇳 Tiếng Việt'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'en',
                          child: Text('🇬🇧 English'),
                        ),
                      ],
                      child: Row(
                        children: [
                          Text(
                            '🇻🇳',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_drop_down, size: 22),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),

          // Wallet Card
          const SizedBox(height: 20),
          _buildWalletCard(),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E9D2D),
            const Color(0xFF0F5418),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Section
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: const Text(
                            'Số dư ví',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            _isHidden ? '*********' : '500.000.000',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.white,
                              fontSize: _isHidden ? 24 : 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isHidden
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Points Section
              Flexible(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: const Text(
                              'hcPoints',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.customer.points.isNotEmpty ? widget.customer.points.first.point : 0}',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Section
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletPage(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white.withOpacity(0.8),
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

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.cleaning_services_rounded,
        'label': 'Dọn dẹp',
        'isNew': true,
      },
      {
        'icon': Icons.child_care_rounded,
        'label': 'Chăm sóc bé',
        'isNew': true,
      },
      {
        'icon': Icons.elderly_rounded,
        'label': 'Chăm sóc người già',
        'isNew': false,
      },
      {
        'icon': Icons.pregnant_woman_rounded,
        'label': 'Chăm sóc sản phụ',
        'isNew': true,
      },
    ];

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
        children: [
          const Text(
            'Dịch vụ nhanh',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.asMap().entries.map((entry) {
              int index = entry.key;
              var action = entry.value;
              bool isNew = (action['isNew'] as bool?) ?? false;

              return Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServicesOrder(
                                  customer: widget.customer,
                                  service: widget.services[index],
                                  services: widget.services,
                                  token: widget.token,
                                  refreshToken: widget.refreshToken,
                                  deviceToken: widget.deviceToken,
                                ),
                              ),
                            );
                          },
                          icon: Icon(
                            action['icon'] as IconData,
                            color: Colors.green.shade700,
                            size: 22,
                          ),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.green.shade50),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(10)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (isNew)
                          Positioned(
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Mới',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerPage = index;
              });
            },
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    bannerImages[index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentBannerPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentBannerPage == index
                    ? Colors.green
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return ServiceListMenu(
      customer: widget.customer,
      services: widget.services,
      token: widget.token,
      refreshToken: widget.refreshToken,
      deviceToken: widget.deviceToken,
    );
  }

  Widget _buildRewardSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'hCRewards',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllRewardsPage(),
                  ),
                );
              },
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CarouselSlider(
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.85,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
          ),
          items: _buildRewardCards(),
        ),
      ],
    );
  }

  List<Widget> _buildRewardCards() {
    final rewards = [
      {'title': 'Giảm 50K khi đặt dịch vụ vệ sinh', 'points': '1,000'},
      {'title': 'Voucher 100K cho khách hàng VIP', 'points': '2,000'},
      {'title': 'Freeship cho đơn hàng trên 500K', 'points': '500'},
      {'title': 'Giảm 20% dịch vụ sửa chữa', 'points': '3,000'},
      {'title': 'Tặng 30K khi đặt dịch vụ trong 3 ngày tới', 'points': '800'},
      {
        'title': 'Hoàn 50% số điểm khi đặt lịch vào cuối tuần',
        'points': '1,500'
      },
      {
        'title': 'Nhận ngay 100K cho lần đặt dịch vụ đầu tiên',
        'points': '2,500'
      },
      {'title': 'Giảm giá 70K cho đơn hàng trên 1 triệu', 'points': '1,200'},
      {'title': 'Tích lũy gấp đôi điểm thưởng tuần này', 'points': '900'},
      {
        'title': 'Ưu đãi đặc biệt: Giảm 150K cho dịch vụ dài hạn',
        'points': '4,000'
      },
    ];

    return rewards.map((reward) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  'lib/images/banner_1.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          reward['title']!,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${reward['points']} điểm',
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> fakePromotions = [
    {
      'title': 'Giảm 50K',
      'subtitle': 'Áp dụng cho đơn hàng từ 300K',
      'imageAsset': 'lib/images/banner_1.png',
    },
    {
      'title': 'Freeship toàn quốc',
      'subtitle': 'Cho mọi đơn hàng từ 200K trở lên',
      'imageAsset': 'lib/images/banner_2.png',
    },
    {
      'title': 'Tặng 20K',
      'subtitle': 'Dành cho khách hàng mới đăng ký',
      'imageAsset': 'lib/images/banner_3.png',
    },
    {
      'title': 'Hoàn 30% điểm thưởng',
      'subtitle': 'Khi thanh toán bằng ví điện tử',
      'imageAsset': 'lib/images/banner_1.png',
    },
    {
      'title': 'Giảm 100K',
      'subtitle': 'Dành cho khách VIP nạp lần đầu',
      'imageAsset': 'lib/images/banner_2.png',
    },
    {
      'title': 'Giảm 10%',
      'subtitle': 'Cho tất cả dịch vụ vào cuối tuần',
      'imageAsset': 'lib/images/banner_3.png',
    },
    {
      'title': 'Tặng 1 lần vệ sinh miễn phí',
      'subtitle': 'Khi đặt lịch dài hạn từ 3 tháng',
      'imageAsset': 'lib/images/banner_1.png',
    },
  ];

  Widget _buildPromotionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Khuyến mãi',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to promotions page
              },
              child: Text(
                'Xem tất cả',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fakePromotions.map((promo) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 48) / 2, // Chia 2 cột
              child: _buildPromotionCard(
                title: promo['title']!,
                subtitle: promo['subtitle']!,
                imageAsset: promo['imageAsset']!,
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildPromotionCard({
    required String title,
    required String subtitle,
    required String imageAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.asset(
              imageAsset,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
