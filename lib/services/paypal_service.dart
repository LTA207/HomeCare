import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalService {
  // PayPal Configuration - Replace with your actual credentials
  static const String _clientId = "AVaWTupcRkM4A1WhRBw-LldnJUP9woJjoa0jd2Sof3zdonijQDhMbqzAUls7ps_sUYv0D4zgDstXyQ5M";
  static const String _clientSecret = "EM0y8Kme-tnSj05a-BC1Xu1w7urtDaOfIz54cz9ytsZyc4XtLpf7V-I1UUvwQlorFEIsl_q5uMW4xJFD";

  // Environment configuration
  static const bool _isSandbox = true; // Set to false for production
  static const String _sandboxUrl = "https://api.sandbox.paypal.com";
  static const String _productionUrl = "https://api.paypal.com";

  static String get _baseUrl => _isSandbox ? _sandboxUrl : _productionUrl;

  static String? _accessToken;
  static DateTime? _tokenExpiry;

  // Step 1: Get OAuth Access Token
  static Future<String?> _getAccessToken() async {
    if (_accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
      return _accessToken;
    }

    try {
      // Check if credentials are properly set
      if (_clientId.isEmpty || _clientSecret.isEmpty) {
        print('PayPal credentials not configured.');
        return null;
      }

      // Encode credentials in base64
      String credentials = base64.encode(utf8.encode('$_clientId:$_clientSecret'));

      print('Requesting PayPal access token...');

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/oauth2/token'),
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'en_US',
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      print('PayPal token response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in'] - 60));
        print('PayPal Access Token obtained successfully');
        return _accessToken;
      } else {
        print('Failed to get PayPal access token: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting PayPal access token: $e');
      return null;
    }
  }

  // Step 2: Create PayPal Order
  static Future<Map<String, dynamic>?> createOrder({
    required double amount,
    required String currency,
    required String description,
  }) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      print('Cannot create order: No access token');
      return null;
    }

    try {
      // Convert VND to USD if needed
      double finalAmount = currency == 'VND' ? convertVNDToUSD(amount) : amount;
      String finalCurrency = currency == 'VND' ? 'USD' : currency;

      final orderData = {
        'intent': 'CAPTURE',
        'purchase_units': [
          {
            'reference_id': 'HOMECARE_${DateTime.now().millisecondsSinceEpoch}',
            'amount': {
              'currency_code': finalCurrency,
              'value': finalAmount.toStringAsFixed(2),
            },
            'description': description,
          }
        ],
        'application_context': {
          'brand_name': 'HomeCare Service',
          'landing_page': 'BILLING',
          'user_action': 'PAY_NOW',
          'return_url': 'https://homecare.app/payment/success',
          'cancel_url': 'https://homecare.app/payment/cancel',
        }
      };

      print('Creating PayPal order with data: ${json.encode(orderData)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/checkout/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'PayPal-Request-Id': 'HOMECARE_${DateTime.now().millisecondsSinceEpoch}',
        },
        body: json.encode(orderData),
      );

      print('PayPal order creation response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Order created successfully with ID: ${responseData['id']}');
        return responseData;
      } else {
        print('Failed to create PayPal order: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating PayPal order: $e');
      return null;
    }
  }

  // Step 3: Get Approval URL from Order Response
  static String? getApprovalUrl(Map<String, dynamic> orderResponse) {
    try {
      final links = orderResponse['links'] as List?;
      if (links != null) {
        for (var link in links) {
          if (link['rel'] == 'approve') {
            return link['href'];
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting approval URL: $e');
      return null;
    }
  }

  // Step 4: Capture Payment after approval
  static Future<Map<String, dynamic>?> captureOrder(String orderId) async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      print('Cannot capture order: No access token');
      return null;
    }

    try {
      print('Capturing PayPal order: $orderId');

      final response = await http.post(
        Uri.parse('$_baseUrl/v2/checkout/orders/$orderId/capture'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
          'PayPal-Request-Id': 'CAPTURE_${DateTime.now().millisecondsSinceEpoch}',
        },
      );

      print('PayPal capture response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Payment captured successfully');
        return responseData;
      } else {
        print('Failed to capture PayPal payment: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error capturing PayPal payment: $e');
      return null;
    }
  }

  // Main payment flow
  static Future<void> makePayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required Function(Map<String, dynamic> params) onSuccess,
    required Function(String error) onError,
    required Function() onCancel,
  }) async {
    try {
      print('Starting PayPal payment flow...');
      print('Amount: $amount, Currency: $currency');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF0070ba)),
              SizedBox(height: 16),
              Text(
                'Đang tạo đơn hàng PayPal...',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

      // Step 2: Create Order
      final orderResponse = await createOrder(
        amount: amount,
        currency: currency,
        description: 'HomeCare Service Payment',
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (orderResponse == null) {
        onError('Không thể tạo đơn hàng PayPal. Vui lòng kiểm tra kết nối mạng.');
        return;
      }

      // Step 3: Get approval URL
      final approvalUrl = getApprovalUrl(orderResponse);
      if (approvalUrl == null) {
        onError('Không tìm thấy URL thanh toán PayPal');
        return;
      }

      final orderId = orderResponse['id'];
      print('Order ID: $orderId');
      print('Approval URL: $approvalUrl');

      // Step 4: Open WebView for payment
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayPalWebView(
            approvalUrl: approvalUrl,
            orderId: orderId,
          ),
        ),
      );

      if (result != null && result['success'] == true) {
        // Step 5: Capture payment
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF0070ba)),
                SizedBox(height: 16),
                Text(
                  'Đang xác nhận thanh toán...',
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

        final captureResponse = await captureOrder(orderId);
        Navigator.of(context).pop(); // Close loading

        if (captureResponse != null && captureResponse['status'] == 'COMPLETED') {
          // Payment successful
          onSuccess(<String, dynamic>{
            "status": "success",
            "payment_method": "paypal",
            "order_id": orderId,
            "capture_id": captureResponse['purchase_units'][0]['payments']['captures'][0]['id'],
            "amount": amount,
            "currency": currency,
            "environment": _isSandbox ? "sandbox" : "production",
            "timestamp": DateTime.now().toIso8601String(),
          });
        } else {
          onError('Không thể xác nhận thanh toán. Vui lòng thử lại.');
        }
      } else if (result != null && result['cancelled'] == true) {
        onCancel();
      } else {
        onError('Thanh toán bị gián đoạn. Vui lòng thử lại.');
      }

    } catch (e) {
      print('Error in PayPal payment flow: $e');
      onError('Lỗi khi xử lý thanh toán PayPal: ${e.toString()}');
    }
  }

  // Convert VND to USD using current exchange rate
  static double convertVNDToUSD(double vndAmount) {
    const double exchangeRate = 24350.0; // Updated exchange rate (VND to USD)
    return vndAmount / exchangeRate;
  }

  // Format amount for display
  static String formatAmount(double amount, String currency) {
    if (currency == 'USD') {
      return "\$${amount.toStringAsFixed(2)}";
    } else if (currency == 'VND') {
      final formatter = NumberFormat("#,###", "vi_VN");
      return "${formatter.format(amount.round())} ₫";
    } else {
      return "${amount.toStringAsFixed(2)} $currency";
    }
  }

  // Validate PayPal credentials
  static Future<bool> validateCredentials() async {
    try {
      print('Validating PayPal credentials...');
      print('Environment: ${_isSandbox ? "Sandbox" : "Production"}');
      print('Base URL: $_baseUrl');

      final token = await _getAccessToken();
      final isValid = token != null;

      print('Credentials validation result: ${isValid ? "SUCCESS" : "FAILED"}');
      return isValid;
    } catch (e) {
      print('Error validating PayPal credentials: $e');
      return false;
    }
  }

  // Get current environment info
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'environment': _isSandbox ? 'sandbox' : 'production',
      'baseUrl': _baseUrl,
      'clientId': _clientId.isNotEmpty ? '${_clientId.substring(0, 10)}...' : 'Not configured',
      'hasValidToken': _accessToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!),
      'isConfigured': _clientId.isNotEmpty && _clientSecret.isNotEmpty,
    };
  }

  // Clear stored tokens
  static void clearTokens() {
    _accessToken = null;
    _tokenExpiry = null;
    print('PayPal tokens cleared');
  }
}

// PayPal WebView Widget for handling payment approval
class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final String orderId;

  const PayPalWebView({
    Key? key,
    required this.approvalUrl,
    required this.orderId,
  }) : super(key: key);

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('PayPal WebView started loading: $url');
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            print('PayPal WebView finished loading: $url');
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            print('PayPal WebView navigation: ${request.url}');

            // Check for success URL
            if (request.url.contains('homecare.app/payment/success') ||
                request.url.contains('paypal.com/checkoutnow/success')) {
              print('Payment approved!');
              Navigator.of(context).pop({'success': true, 'orderId': widget.orderId});
              return NavigationDecision.prevent;
            }

            // Check for cancel URL
            if (request.url.contains('homecare.app/payment/cancel') ||
                request.url.contains('paypal.com/checkoutnow/cancel')) {
              print('Payment cancelled by user');
              Navigator.of(context).pop({'cancelled': true});
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF0070ba),
        title: Text(
          'PayPal Payment',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop({'cancelled': true});
          },
        ),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0070ba)),
                  SizedBox(height: 16),
                  Text(
                    'Đang tải PayPal...',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
