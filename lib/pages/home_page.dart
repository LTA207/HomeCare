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

    // Load data first, then set up notifications
    loadRequestData().then((_) {
      setState(() {
        todayRequests = getTodayRequests();
        _showPinnedNotification = todayRequests.isNotEmpty;
      });
    });

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
    // Load all request data fresh from server
    loadRequestData().then((_) {
      if (mounted) {
        setState(() {
          // Get today's requests with proper filtering
          todayRequests = getTodayRequests();

          // Update notification state based on filtered results
          if (todayRequests.isNotEmpty) {
            _showPinnedNotification = true;
            // Reset to first request if current index is out of bounds
            if (_currentRequestIndex >= todayRequests.length) {
              _currentRequestIndex = 0;
            }
          } else {
            _showPinnedNotification = false;
            _currentRequestIndex = 0;
          }
        });
      }
    }).catchError((error) {
      // Handle error silently or add proper error handling
    });
  }

  void _checkAndSwitchRequest(String orderId) {
    // Reload all data to ensure we have the latest status
    _handleFCMNotification();
  }

  Future<void> loadRequestData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCustomerRequest(
        widget.customer.phone, widget.token);
    // Chỉ cập nhật data, không setState ở đây
    requestCustomer = data ?? [];
  }

  Future<void> loadHelperData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCleanerData();
    helperList = data ?? [];
  }

  List<Requests> getTodayRequests() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (requestCustomer == null || requestCustomer!.isEmpty) {
      return [];
    }

    final filteredRequests = requestCustomer!.where((request) {
      try {
        final startDateTime = DateTime.parse(request.startTime);
        final startDate = DateTime(startDateTime.year, startDateTime.month, startDateTime.day);

        // Filtering criteria:
        // 1. Request is for today
        final isToday = startDate == today;

        // 2. Start time is in the future
        final isFuture = startDateTime.isAfter(now);

        // 3. Status is pending (case insensitive)
        final isPending = request.status.toLowerCase() == 'pending';

        final shouldInclude = isToday && isFuture && isPending;

        return shouldInclude;
      } catch (e) {
        return false;
      }
    }).toList();

    // Sort by start time (earliest first)
    filteredRequests.sort((a, b) {
      try {
        final aTime = DateTime.parse(a.startTime);
        final bTime = DateTime.parse(b.startTime);
        return aTime.compareTo(bTime);
      } catch (e) {
        return 0;
      }
    });

    return filteredRequests;
  }

  @override
  Widget build(BuildContext context) {
    // Remove this condition - let initState handle the initialization
    // if (todayRequests.isEmpty) {
    //   todayRequests = getTodayRequests();
    // }

    final hasValidRequest = todayRequests.isNotEmpty && _currentRequestIndex < todayRequests.length;
    final currentRequest = hasValidRequest ? todayRequests[_currentRequestIndex] : null;

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
                          Row(
                            children: [
                              Text(
                                'Nhấn để xem chi tiết',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                  fontSize: 11,
                                  fontFamily: 'Quicksand',
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              if (todayRequests.length > 1) ...[
                                const Spacer(),
                                Text(
                                  '${_currentRequestIndex + 1}/${todayRequests.length}',
                                  style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontSize: 10,
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (todayRequests.length > 1) ...[
                      IconButton(
                        icon: const Icon(Icons.navigate_before, color: Colors.green, size: 22),
                        onPressed: _currentRequestIndex > 0 ? () {
                          setState(() {
                            _currentRequestIndex--;
                          });
                        } : null,
                        tooltip: 'Đơn hàng trước',
                      ),
                      IconButton(
                        icon: const Icon(Icons.navigate_next, color: Colors.green, size: 22),
                        onPressed: _currentRequestIndex < todayRequests.length - 1 ? () {
                          setState(() {
                            _currentRequestIndex++;
                          });
                        } : null,
                        tooltip: 'Đơn hàng tiếp theo',
                      ),
                    ],
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
