import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:foodapp/services/notification_service.dart';

class FirebaseMessagingService {
  static FirebaseMessagingService? _instance;
  static FirebaseMessagingService get instance => _instance ??= FirebaseMessagingService._();

  FirebaseMessagingService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Callback để thông báo cho UI cần refresh data
  static Function()? onDataChanged;
  // Callback để xử lý orderId từ FCM notification
  static Function(String orderId)? onOrderIdReceived;

  Future<void> initialize() async {
    try {
      // Initialize NotificationService
      await NotificationService.init();

      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('📱 User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('📱 User granted provisional permission');
      } else {
        print('❌ User declined or has not accepted permission');
      }

      // Get the token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('📋 FCM Token: $token');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        print('📋 FCM Token refreshed: $token');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('🔔 Received foreground message: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // Handle messages when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('🔔 App opened from background message: ${message.notification?.title}');
        _handleBackgroundMessage(message);
      });

    } catch (e) {
      print('❌ Error initializing Firebase Messaging: $e');
      rethrow;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling foreground message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Kiểm tra nếu có orderId trong data
    if (message.data.containsKey('orderId')) {
      String orderId = message.data['orderId'];
      print('📦 Received orderId: $orderId');

      // Gọi callback để xử lý orderId
      onOrderIdReceived?.call(orderId);
    }

    // Kiểm tra nếu là thông báo cập nhật trạng thái
    if (message.data.containsKey('type') && message.data['type'] == 'status_update') {
      String status = message.data['status'] ?? '';
      String requestId = message.data['requestId'] ?? '';

      // Hiển thị thông báo in-app cho status update
      NotificationService.showStatusUpdateNotification(
        title: message.notification?.title ?? 'Cập nhật trạng thái',
        message: message.notification?.body ?? 'Yêu cầu của bạn đã được cập nhật',
        status: status,
        onTap: () {
          // Trigger refresh data callback
          onDataChanged?.call();
        },
      );
    } else {
      // Hiển thị thông báo in-app thông thường
      NotificationService.showInAppNotification(
        title: message.notification?.title ?? 'Thông báo',
        body: message.notification?.body ?? 'Bạn có thông báo mới',
        onTap: () {
          // Trigger refresh data callback
          onDataChanged?.call();
        },
      );
    }

    // Trigger refresh data callback
    onDataChanged?.call();
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('Handling background message: ${message.messageId}');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }

    // Kiểm tra nếu có orderId trong data
    if (message.data.containsKey('orderId')) {
      String orderId = message.data['orderId'];
      print('📦 Received orderId from background: $orderId');

      // Gọi callback để xử lý orderId
      onOrderIdReceived?.call(orderId);
    }

    // Trigger refresh data callback khi app được mở từ notification
    onDataChanged?.call();
  }

  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // Method để đăng ký callback từ UI
  static void setDataChangeCallback(Function() callback) {
    onDataChanged = callback;
  }

  // Method để đăng ký callback cho orderId
  static void setOrderIdCallback(Function(String) callback) {
    onOrderIdReceived = callback;
  }

  // Method để hủy đăng ký callback
  static void clearDataChangeCallback() {
    onDataChanged = null;
  }

  // Method để hủy đăng ký callback orderId
  static void clearOrderIdCallback() {
    onOrderIdReceived = null;
  }
}
