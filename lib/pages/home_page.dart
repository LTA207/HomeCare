import 'package:flutter/material.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/pages/activity_page.dart';
import 'package:foodapp/pages/notification_page.dart';
import 'package:foodapp/pages/order_detail_longterm_page.dart';
import 'package:foodapp/pages/order_detail_page.dart';
import 'package:foodapp/pages/profile_page.dart';
import '../data/model/request.dart';
import '../data/model/service.dart';
import '../services/firebase_messaging_service.dart';

import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../data/repository/repository.dart';
import 'home_content_page.dart';

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
  List<Requests>? requestCustomer = [];
  List<Requests> todayRequests = [];
  List<Helper> helperList = [];
  bool _showPinnedNotification = true;
  int _currentRequestIndex = 0;

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
    loadRequestData();

    // Đăng ký callback FCM để xử lý thông báo
    FirebaseMessagingService.setDataChangeCallback(_handleFCMNotification);
    FirebaseMessagingService.setOrderIdCallback(_checkAndSwitchRequest);
  }

  @override
  void dispose() {
    // Hủy đăng ký callback khi widget bị dispose
    FirebaseMessagingService.clearDataChangeCallback();
    FirebaseMessagingService.clearOrderIdCallback();
    super.dispose();
  }

  void _handleFCMNotification() {
    loadRequestData().then((_) {
      setState(() {
        todayRequests = getTodayRequests();
      });
    });
  }

  void _checkAndSwitchRequest(String orderId) {
    setState(() {
      todayRequests.removeWhere((request) => request.id == orderId);

      if (todayRequests.isEmpty) {
        _showPinnedNotification = false;
        _currentRequestIndex = 0;
      } else {
        if (_currentRequestIndex >= todayRequests.length) {
          _currentRequestIndex = todayRequests.length - 1;
        }
      }
    });

    print('📦 Removed request with orderId: $orderId');
    print('📋 Remaining today requests: ${todayRequests.length}');
  }

  Future<void> loadRequestData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCustomerRequest(
        widget.customer.phone, widget.token);
    // Chỉ cập nhật data, không setState ở đây
    requestCustomer = data ?? [];
    print('đã tải lại request data');
    print(
        'Yêu cầu của khách hàng: ${requestCustomer?.where((req) => req.id == '68ba7a9059afc945c946f477').toList()}');
  }

  Future<void> loadHelperData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCleanerData();
    helperList = data ?? [];
  }

  List<Requests> getTodayRequests() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final list = (requestCustomer ?? []).where((request) {
      try {
        final startDate = DateTime.parse(request.startTime);
        final startDay =
            DateTime(startDate.year, startDate.month, startDate.day);

        return startDay == today && !startDate.isBefore(now);
      } catch (_) {
        return false;
      }
    }).toList();

    list.sort((a, b) {
      final aTime = DateTime.parse(a.startTime);
      final bTime = DateTime.parse(b.startTime);
      return aTime.compareTo(bTime);
    });

    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (todayRequests.isEmpty) {
      todayRequests = getTodayRequests();
    }

    final hasValidRequest =
        todayRequests.isNotEmpty && _currentRequestIndex < todayRequests.length;
    final currentRequest =
        hasValidRequest ? todayRequests[_currentRequestIndex] : null;

    print('Yêu cầu hôm nay: $todayRequests');
    return Scaffold(
      body: _pages[_selectedIndex.clamp(0, _pages.length - 1)],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showPinnedNotification && currentRequest != null)
            GestureDetector(
              onTap: () => _handleNotificationTap(currentRequest),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 2),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent.shade100,
                  border: Border(
                    top: BorderSide(color: Colors.green.shade200, width: 1),
                    bottom: BorderSide(color: Colors.green.shade200, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_available,
                        color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bạn có đơn hàng sắp tới - ${currentRequest.service.title}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Quicksand',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatRequestTime(currentRequest),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontFamily: 'Quicksand',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nhấn để xem chi tiết',
                            style: TextStyle(
                              color: Colors.green.shade600,
                              fontSize: 11,
                              fontFamily: 'Quicksand',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.close, color: Colors.grey, size: 22),
                      onPressed: () {
                        setState(() {
                          _showPinnedNotification = false;
                        });
                      },
                      tooltip: 'Đóng thông báo',
                    ),
                  ],
                ),
              ),
            ),
          Container(
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
        ],
      ),
    );
  }

  void _handleNotificationTap(Requests request) {
    if (request.requestType == "Ngắn hạn") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailPage(
            request: request,
            helpers: helperList,
            services: widget.services,
            customer: widget.customer,
            token: widget.token,
            refreshToken: widget.refreshToken,
            deviceToken: widget.deviceToken,
            requestDetail: request.schedules.first,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailLongTermPage(
              requestDetail: request.schedules,
              helpers: helperList,
              services: widget.services,
              customer: widget.customer,
              request: request,
              token: widget.token,
              refreshToken: widget.refreshToken,
              deviceToken: widget.deviceToken,
          ),
        ),
      );
    }
  }

  String _formatRequestTime(Requests request) {
    try {
      final startTime = DateTime.parse(request.startTime);
      final endTime = DateTime.parse(request.endTime);

      final startHour = startTime.hour.toString().padLeft(2, '0');
      final startMinute = startTime.minute.toString().padLeft(2, '0');
      final endHour = endTime.hour.toString().padLeft(2, '0');
      final endMinute = endTime.minute.toString().padLeft(2, '0');

      final day = startTime.day.toString().padLeft(2, '0');
      final month = startTime.month.toString().padLeft(2, '0');
      final year = startTime.year;

      return '$startHour:$startMinute - $endHour:$endMinute, $day/$month/$year';
    } catch (e) {
      return 'Thời gian không xác định';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
