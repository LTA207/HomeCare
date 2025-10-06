import 'package:flutter/material.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/pages/helper_detail_page.dart';
import 'package:intl/intl.dart';

import '../data/model/customer.dart';
import '../data/model/request.dart';
import '../data/model/service.dart';
import '../data/repository/repository.dart';
import 'home_page.dart';

class ReviewOrderPage extends StatefulWidget {
  final Customer customer;
  final Helper? helper;
  final Requests request;
  final List<Services> services;
  final Services service;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const ReviewOrderPage({
    super.key,
    required this.customer,
    this.helper,
    required this.request,
    required this.services,
    required this.service,
    required this.token,
    required this.refreshToken,
    required this.deviceToken,
  });

  @override
  _ReviewOrderPageState createState() => _ReviewOrderPageState();
}

class _ReviewOrderPageState extends State<ReviewOrderPage> {
  // Remove payment-related variables
  Map<String, dynamic>? detailCost;
  List<Map<String, dynamic>?> singleDayCostData = [];
  Map<String, dynamic> costData = {};

  num finalCost = 0;
  num workingTime = 0;
  bool isOnDemand = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCostData();
  }

  Future<void> loadCostData() async {
    List<String>? dateList = widget.request.startDate?.split(",");
    if (dateList!.length > 1) isOnDemand = false;
    for (var date in dateList) {
      var data = await getDetailCost(widget.service.title,
          widget.request.startTime, widget.request.endTime, date);
      setState(() {
        singleDayCostData.add(data);
        costData = data!;
        isLoading = false;
      });
      finalCost += costData["finalCost"] ?? 0;
      workingTime += costData["workingTime"] ?? 0;
      print('cost data fgdfgdfgdgdfg: ${singleDayCostData.length}');
      print('gfdggggggggggggggggggdgdfgdgjkllkjhj $singleDayCostData');
    }
  }

  Future<Map<String, dynamic>?> getDetailCost(
      String service, String startTime, String endTime, String workDate) async {
    var repository = DefaultRepository();
    print(service);
    print(startTime);
    print(endTime);
    print(workDate);
    var data = await repository.calculateCost(
        service, getHourMinute(startTime), getHourMinute(endTime), workDate);
    print('data: $data');
    return {
      'workingTime': data?['totalOvertimeHours'] + data?['totalNormalHours'],
      'basicPrice': data?['servicePrice'],
      'basicCoefficient': data?['HSDV'],
      'overTimeCoefficient': data?['HSovertime'],
      'overTimeHours': data?['totalOvertimeHours'],
      'finalCost': data?['totalCost'],
      // 'overTimeCost': overTime * maxCoefficient * basicPrice * basicCoefficient,
      'overtimeCost': data?['overtimeCost']
    };
  }

  String getHourMinute(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    num totalCost = 0;

    String? _formatDate(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;

      List<String> dates = dateString.split(",");
      List<String> formattedDates = dates.map((date) {
        try {
          DateTime parsedDate = DateTime.parse(date);
          return DateFormat('dd/MM').format(parsedDate);
        } catch (e) {
          return date; // Trả lại nguyên gốc nếu lỗi
        }
      }).toList();

      return formattedDates.join(", ");
    }

    String _formatTime(double workingTime) {
      double roundedTime = double.parse(workingTime.toStringAsFixed(2));
      num hours = roundedTime.floor();
      num minutes = ((roundedTime - hours) * 60).round();

      if (minutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $minutes phút';
      }
    }
    //
    // print(totalCost);
    // print(widget.request.startDate);
    // print('thông tin request: ${widget.request}');

    // final basePrice = costData['basePrice'] ?? 0.0;
    // final basicCoefficient = costData['basicCoefficient'] ?? 0.0;
    // final overTimeHours = costData['overTimeHours'] ?? 0.0;
    // final overTimeCoefficient = costData['overTimeCoefficient'] ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // _buildSectionTitle('Vị trí làm việc'),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Vị trí làm việc'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.location_on_rounded,
                          color: Color(0xFF2E7D32)),
                    ),
                    title: Text(
                      widget.request.customerInfo.address,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      // '${widget.customer.addresses[0].district}, ${widget.customer.addresses[0].province}',
                      '${widget.request.location.ward}, ${widget.request.location.province}',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Divider(
                    height: 24,
                    color: Colors.grey.shade200,
                  ),
                  _buildSectionTitle('Người giúp việc'),
                  ListTile(
                    onTap: () {
                      if (widget.helper != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HelperDetailPage(
                              helper: widget.helper!,
                              services: widget.services,
                            ),
                          ),
                        );
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: widget.helper?.avatar != null &&
                              widget.helper!.avatar!.isNotEmpty
                          ? ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: Image.network(
                                widget.helper!.avatar!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.person, color: Colors.green),
                    ),
                    title: Text(
                      widget.helper?.fullName ?? 'Hệ thống chọn',
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      widget.helper?.phone ?? "Không có số điện thoại",
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // _buildSectionTitle('Thông tin công việc'),

            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Thời gian làm việc',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Color(0xFF2E7D32),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Ngày làm việc',
                      _formatDate(widget.request.startDate) ?? 'N/A'),
                  _buildInfoRow(
                    'Làm trong',
                    // '${(DateTime.parse(widget.request.endTime).difference(DateTime.parse(widget.request.startTime))).inHours} giờ, ${(widget.request.startTime)} - ${widget.request.endTime}'
                    // '${(DateTime.parse(widget.request.endTime).difference(DateTime.parse(widget.request.startTime))).inHours} giờ, ${DateTime.parse(widget.request.startTime).hour}:${DateTime.parse(widget.request.startTime).minute} - ${DateTime.parse(widget.request.endTime).hour}:${DateTime.parse(widget.request.endTime).minute}',
                    _formatTime(workingTime.toDouble()),
                  ),
                  Divider(
                    height: 24,
                    color: Colors.grey.shade200,
                  ),
                  const Text(
                    'Chi tiết dịch vụ',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                      'Loại dịch vụ', widget.request.service.title ?? 'N/A'),
                ],
              ),
            ),
            // _buildSectionTitle('Chi phí dịch vụ'),

            isOnDemand
                ? _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Chi phí dịch vụ',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _buildInfoRow(
                          'Số giờ làm hành chính',
                          _formatTime((costData['workingTime'] -
                                  costData['overTimeHours'])
                              .toDouble()),
                        ),
                        _buildInfoRow(
                            'Giá cơ bản',
                            _formatCurrency(costData['basicPrice'].toDouble() *
                                costData['basicCoefficient'].toDouble())),
                        _buildInfoRow(
                          'Số giờ làm ngoài giờ',
                          // '${costData['overTimeHours']} giờ',
                          _formatTime(costData['overTimeHours'].toDouble()),
                        ),
                        _buildInfoRow(
                          'Giá dịch vụ ngoài giờ',
                          // '${costData['overTimeCost']}'),
                          _formatCurrency(costData['overtimeCost'].toDouble()),
                        ),
                        Divider(
                          height: 24,
                          color: Colors.grey.shade200,
                        ),
                        _buildInfoRow(
                          'Tổng chi phí dịch vụ',
                          // '${costData['finalCost']} VNĐ',
                          // '$finalCost đ',
                          _formatCurrency(finalCost.toDouble()),
                        ),
                      ],
                    ),
                  )
                : _buildCard(
                    child: Column(
                      children: [
                        Text(
                          'Chi phí dịch vụ',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Column(
                          children: [
                            // Chi phí từng ngày
                            for (int index = 0;
                                index < singleDayCostData.length;
                                index++)
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16), // Khoảng cách giữa các item
                                child: _buildInfoRow(
                                  'Chi phí ngày ${_formatDate(widget.request.startDate?.split(',')[index])}',
                                  _formatCurrency(double.parse(
                                      '${singleDayCostData[index]?['finalCost']}')),
                                  buttonText: 'Xem chi tiết',
                                  onPressed: () {
                                    showCostDetailsPopup(
                                        context,
                                        singleDayCostData[index]!,
                                        widget.request.startDate!
                                            .split(',')[index]);
                                  },
                                ),
                              ),
                            Divider(
                              height: 24,
                              color: Colors.grey.shade200,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16), // Khoảng cách giữa các item
                              child: _buildInfoRow(
                                'Tổng chi phí dịch vụ',
                                _formatCurrency(finalCost.toDouble()),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
            // _buildSectionTitle('Phương thức thanh toán'),
            // _buildCard(
            //   child: Column(
            //     children: [
            //       Text('Phương thức thanh toán',
            //           style: TextStyle(
            //             fontFamily: 'Quicksand',
            //             fontSize: 16,
            //             color: Color(0xFF2E7D32),
            //             fontWeight: FontWeight.w800,
            //           )),
            //       const SizedBox(height: 12),
            //       RadioListTile(
            //         value: true,
            //         groupValue: isOnlinePayment,
            //         onChanged: (value) {
            //           setState(() {
            //             isOnlinePayment = value!;
            //           });
            //         },
            //         title: const Text(
            //           'Chuyển khoản',
            //           style: TextStyle(
            //             fontFamily: 'Quicksand',
            //             fontSize: 16,
            //             fontWeight: FontWeight.w400,
            //           ),
            //         ),
            //         activeColor: const Color(0xFF2E7D32),
            //       ),
            //       RadioListTile(
            //         value: false,
            //         groupValue: isOnlinePayment,
            //         onChanged: (value) {
            //           setState(() {
            //             isOnlinePayment = value!;
            //           });
            //         },
            //         title: const Text(
            //           'Thanh toán tiền mặt',
            //           style: TextStyle(
            //             fontFamily: 'Quicksand',
            //             fontSize: 16,
            //             fontWeight: FontWeight.w400,
            //           ),
            //         ),
            //         activeColor: const Color(0xFF2E7D32),
            //       ),
            //     ],
            //   ),
            // ),
            // _buildCard(
            //   child: Column(
            //     children: [
            //       Text('Phương thức thanh toán',
            //           style: TextStyle(
            //             fontFamily: 'Quicksand',
            //             fontSize: 16,
            //             color: Color(0xFF2E7D32),
            //             fontWeight: FontWeight.w700,
            //           )),
            //       const SizedBox(height: 12),
            //       RadioListTile(
            //         value: 'cash',
            //         groupValue: selectedPaymentMethod,
            //         onChanged: (value) {
            //           setState(() {
            //             selectedPaymentMethod = value!;
            //             isOnlinePayment = false;
            //           });
            //         },
            //         title: const Text(
            //           'Thanh toán tiền mặt',
            //           style: TextStyle(
            //             fontFamily: 'Quicksand',
            //             fontSize: 16,
            //             fontWeight: FontWeight.w400,
            //           ),
            //         ),
            //         activeColor: const Color(0xFF2E7D32),
            //       ),
            //       RadioListTile(
            //         value: 'transfer',
            //         groupValue: selectedPaymentMethod,
            //         onChanged: (value) {
            //           setState(() {
            //             selectedPaymentMethod = value!;
            //             isOnlinePayment = true;
            //           });
            //         },
            //         title: const Text(
            //           'Chuyển khoản ngân hàng',
            //           style: TextStyle(
            //             fontFamily: 'Quicksand',
            //             fontSize: 16,
            //             fontWeight: FontWeight.w400,
            //           ),
            //         ),
            //         activeColor: const Color(0xFF2E7D32),
            //       ),
            //       RadioListTile(
            //         value: 'paypal',
            //         groupValue: selectedPaymentMethod,
            //         onChanged: (value) {
            //           setState(() {
            //             selectedPaymentMethod = value!;
            //             isOnlinePayment = true;
            //           });
            //         },
            //         title: Row(
            //           children: [
            //             Icon(Icons.payment, color: Color(0xFF0070ba), size: 24),
            //             const SizedBox(width: 8),
            //             Flexible(
            //               child: const Text(
            //                 'PayPal',
            //                 style: TextStyle(
            //                   fontFamily: 'Quicksand',
            //                   fontSize: 16,
            //                   fontWeight: FontWeight.w400,
            //                 ),
            //                 overflow: TextOverflow.ellipsis,
            //               ),
            //             ),
            //           ],
            //         ),
            //         activeColor: const Color(0xFF2E7D32),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _handleJobPosting(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Đăng việc",
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleJobPosting() {
    widget.request.totalCost = finalCost;

    var repository = DefaultRepository();
    repository.sendRequest(widget.request, widget.token);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                "Đăng việc thành công!",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            "Yêu cầu dịch vụ của bạn đã được đăng thành công.\nChúng tôi sẽ tìm kiếm người giúp việc phù hợp cho bạn.",
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _navigateToHome();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Về trang chủ",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Quicksand',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHome() {
    // Navigate back to home page by popping all routes until the first one
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(
          customer: widget.customer,
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

  // Helper method to build cards with consistent styling
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: child,
    );
  }

  // Helper method to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }

  // Helper method to build info rows
  Widget _buildInfoRow(String label, String value,
      {String? buttonText, VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Quicksand',
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                if (buttonText != null && onPressed != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format currency
  String _formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    int roundedAmount = (amount / 1000).ceil() * 1000;
    return "${formatter.format(roundedAmount)} đ";
  }

  // Method to show cost details popup for multi-day orders
  void showCostDetailsPopup(
      BuildContext context, Map<String, dynamic> costData, String date) {
    String _formatDate(String dateString) {
      try {
        DateTime parsedDate = DateTime.parse(dateString);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        return dateString;
      }
    }

    String _formatTime(double workingTime) {
      double roundedTime = double.parse(workingTime.toStringAsFixed(2));
      num hours = roundedTime.floor();
      num minutes = ((roundedTime - hours) * 60).round();

      if (minutes == 0) {
        return '$hours giờ';
      } else {
        return '$hours giờ $minutes phút';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chi tiết ngày ${_formatDate(date)}',
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow(
                  'Số giờ làm hành chính',
                  _formatTime(
                      (costData['workingTime'] - costData['overTimeHours'])
                          .toDouble()),
                ),
                _buildInfoRow(
                  'Giá cơ bản',
                  _formatCurrency(costData['basicPrice'].toDouble() *
                      costData['basicCoefficient'].toDouble()),
                ),
                _buildInfoRow(
                  'Số giờ làm ngoài giờ',
                  _formatTime(costData['overTimeHours'].toDouble()),
                ),
                _buildInfoRow(
                  'Giá dịch vụ ngoài giờ',
                  _formatCurrency(costData['overtimeCost'].toDouble()),
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  'Tổng chi phí',
                  _formatCurrency(costData['finalCost'].toDouble()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
