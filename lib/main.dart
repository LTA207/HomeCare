import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/components/spashscreen.dart';
import 'package:foodapp/themes/theme_provider.dart';
import 'package:foodapp/providers/auth_provider.dart';
import 'package:foodapp/services/firebase_messaging_service.dart';
import 'package:overlay_support/overlay_support.dart';
import 'firebase_options.dart'; // Thêm import này

import 'components/request_provider.dart';
import 'data/repository/repository.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Kiểm tra và khởi tạo Firebase an toàn cho background handler
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  print("🔔 Nhận thông báo trong nền: ");
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Data: ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String deviceToken = '';

  // Kiểm tra và khởi tạo Firebase an toàn
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("🔥 Firebase initialized successfully");
    } else {
      print("🔥 Firebase already initialized");
    }
  } catch (e) {
    print("❌ Error initializing Firebase: $e");
  }

  // Thiết lập background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Xóa token cũ và tạo token mới
  try {
    await FirebaseMessaging.instance.deleteToken();
    print("🗑️ Đã xóa token cũ");

    // Tạo token mới
    String? newToken = await FirebaseMessaging.instance.getToken();
    if (newToken == null) {
      throw Exception("Token mới trả về null");
    }
    deviceToken = newToken;
    print("🔥 FCM TOKEN MỚI:");
    print(newToken);
    print("📋 Copy token này và dùng trong Firebase Console");
  } catch (e) {
    print("❌ Lỗi khi xử lý token: $e");
  }

  // Khởi tạo FCM service
  try {
    await FirebaseMessagingService.instance.initialize();
    print("📱 Firebase Messaging Service initialized");
  } catch (e) {
    print("❌ Error initializing FCM service: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => RequestProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MyApp(deviceToken: deviceToken,),
    ),
  );
}



class MyApp extends StatelessWidget {
  final String deviceToken;
  const MyApp({super.key, required this.deviceToken});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: context.watch<ThemeProvider>().themeData,
        home: SplashScreen(deviceToken: deviceToken,),
      ),
    );
  }
}

// void main() async{
//   String phone = '0987654321';
//   String fullName = 'Nguyen Van A';
//   String password = '123456';
//   String email = 'trongc71@gmail.com';
//   String requestId = "68e3d1c93e63520fb948c5db";
//   String helperId = "68b9077dc29b592b8c405d3b";
//   // Addresses address = Addresses(
//   //   province: 'Hà Nội',
//   //   district: 'Hà Đông',
//   //   ward: 'Phú Lãm',
//   //   detailedAddress: 'Số 123, Đường ABC',
//   // );
//
//   var repository = DefaultRepository();
//   var data = await repository.loginCustomer(phone, password);
//   print('Login data: ${data.toString()}');
//   var locationData = await repository.loadHelperRequestDetail(helperId, data!.accessToken);
//   print('Location data: ${locationData?.length}');
//   // var listDetail = locationData
//   //     ?.expand((loc) => loc.schedules)
//   //     .where((e) => e.helperID == helperId)
//   //     .toList();
//   // print('Location data: ${listDetail?.length}');
//   // var requestData = await repository.loadCustomerRequest(phone, data!.accessToken);
//   // print('Request data: ${requestData?.first.schedules.toString()}');
//   // var registerData = await repository.registerCustomer(
//   //   '4795335132',
//   //   password,
//   //   fullName,
//   //   email,
//   //   Addresses(
//   //     province: 'Hà Nội',
//   //     district: 'Hà Đông',
//   //     ward: 'Phú Lãm',
//   //     detailedAddress: 'Số 123, Đường ABC',
//   //   ),
//   // );
//   // print('Register data: ${registerData.toString()}');
//   // var customerData = await repository.loadCustomerInfo(data!.user.phone, data.accessToken);
//   // print('Customer data: ${customerData.toString()}');
//   // var requestData = await repository.loadCustomerRequest(data.user.phone, data.accessToken);
//   // print('Request data: ${requestData.toString()}');
//   // var requestDetailData = await repository.loadCustomerRequest(phone, data!.accessToken);
//   // print('Request detail data: ${requestDetailData?.first.schedules}');
// }
