import 'package:flutter/material.dart';
import 'package:foodapp/services/paypal_service.dart';
import 'package:intl/intl.dart';

class PayPalTestPage extends StatefulWidget {
  final num amount;
  final String orderDetails;

  const PayPalTestPage({
    super.key,
    required this.amount,
    required this.orderDetails,
  });

  @override
  State<PayPalTestPage> createState() => _PayPalTestPageState();
}

class _PayPalTestPageState extends State<PayPalTestPage> {
  bool isProcessing = false;
  String paymentStatus = "";
  bool isValidatingCredentials = true;
  bool credentialsValid = false;

  @override
  void initState() {
    super.initState();
    _validatePayPalCredentials();
  }

  Future<void> _validatePayPalCredentials() async {
    try {
      final isValid = await PayPalService.validateCredentials();
      setState(() {
        credentialsValid = isValid;
        isValidatingCredentials = false;
      });
    } catch (e) {
      setState(() {
        credentialsValid = false;
        isValidatingCredentials = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    int roundedAmount = (amount / 1000).ceil() * 1000;
    return "${formatter.format(roundedAmount)} đ";
  }

  void _processPayPalPayment() {
    setState(() {
      isProcessing = true;
      paymentStatus = "Đang khởi tạo thanh toán PayPal...";
    });

    PayPalService.makePayment(
      context: context,
      amount: widget.amount.toDouble(),
      currency: 'VND',
      onSuccess: (params) {
        setState(() {
          isProcessing = false;
          paymentStatus = "Thanh toán thành công! ✅\nOrder ID: ${params['order_id'] ?? 'N/A'}";
        });
        _showSuccessDialog(params);
      },
      onError: (error) {
        setState(() {
          isProcessing = false;
          paymentStatus = "Thanh toán thất bại: $error ❌";
        });
        _showErrorDialog(error);
      },
      onCancel: () {
        setState(() {
          isProcessing = false;
          paymentStatus = "Thanh toán đã bị hủy 🚫";
        });
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> params) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text(
                "Thành công!",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Thanh toán PayPal đã được xử lý thành công!",
                style: const TextStyle(fontFamily: 'Quicksand'),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết thanh toán:',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Số tiền: ${_formatCurrency(widget.amount.toDouble())}',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.green[600],
                      ),
                    ),
                    Text(
                      'Order ID: ${params['order_id'] ?? 'N/A'}',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Colors.green[600],
                      ),
                    ),
                    Text(
                      'Capture ID: ${params['capture_id'] ?? 'N/A'}',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop('payment_success'); // Return to review order
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                "Quay lại",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                "Lỗi thanh toán",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Text(
            error,
            style: const TextStyle(fontFamily: 'Quicksand'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Thử lại",
                style: TextStyle(
                  color: Colors.blue,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop('payment_failed');
              },
              child: const Text(
                "Quay lại",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Quicksand',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isValidatingCredentials) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xFF0070ba),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'PayPal Payment',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF0070ba)),
              SizedBox(height: 16),
              Text(
                'Đang xác thực PayPal API...',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final envInfo = PayPalService.getEnvironmentInfo();
    final isConfigured = envInfo['isConfigured'] as bool;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFF0070ba),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PayPal Payment',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PayPal Status Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: credentialsValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: credentialsValid ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                credentialsValid ? Icons.check_circle : Icons.error,
                                color: credentialsValid ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  credentialsValid
                                    ? 'PayPal API kết nối thành công'
                                    : 'Lỗi kết nối PayPal API',
                                  style: TextStyle(
                                    fontFamily: 'Quicksand',
                                    fontWeight: FontWeight.w600,
                                    color: credentialsValid ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Môi trường: ${envInfo['environment']?.toString().toUpperCase()}',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              color: credentialsValid ? Colors.green[600] : Colors.red[600],
                            ),
                          ),
                          Text(
                            'Client ID: ${envInfo['clientId']}',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 12,
                              color: credentialsValid ? Colors.green[600] : Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // PayPal Logo and Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.payment, color: Color(0xFF0070ba), size: 32),
                                SizedBox(width: 12),
                                Text(
                                  'PayPal',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0070ba),
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Complete PayPal API Integration',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontFamily: 'Quicksand',
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Order Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color.fromARGB(255, 239, 246, 240),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chi tiết thanh toán',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          SizedBox(height: 16),
                          _buildInfoRow('Dịch vụ', widget.orderDetails),
                          _buildInfoRow('Số tiền (VND)', _formatCurrency(widget.amount.toDouble())),
                          _buildInfoRow('Số tiền (USD)', PayPalService.formatAmount(PayPalService.convertVNDToUSD(widget.amount.toDouble()), 'USD')),
                          _buildInfoRow('Môi trường', envInfo['environment']?.toString().toUpperCase() ?? 'N/A'),
                          _buildInfoRow('Trạng thái API', credentialsValid ? 'Sẵn sàng' : 'Lỗi kết nối'),
                          if (paymentStatus.isNotEmpty) ...[
                            SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: paymentStatus.contains('thành công')
                                    ? Colors.green.withOpacity(0.1)
                                    : paymentStatus.contains('thất bại')
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: paymentStatus.contains('thành công')
                                      ? Colors.green
                                      : paymentStatus.contains('thất bại')
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                              child: Text(
                                paymentStatus,
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                  color: paymentStatus.contains('thành công')
                                      ? Colors.green[700]
                                      : paymentStatus.contains('thất bại')
                                          ? Colors.red[700]
                                          : Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Payment Flow Information
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Quy trình PayPal API:',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '1. Lấy Access Token từ PayPal\n'
                            '2. Tạo Order với PayPal API\n'
                            '3. Mở WebView cho người dùng thanh toán\n'
                            '4. Xử lý redirect từ PayPal\n'
                            '5. Capture thanh toán để hoàn tất',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 14,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (isProcessing || !credentialsValid) ? null : _processPayPalPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: credentialsValid ? Color(0xFF0070ba) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isProcessing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Đang xử lý thanh toán...",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            credentialsValid ? "Thanh toán với PayPal" : "PayPal không khả dụng",
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Quay lại Review Order",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
