import 'package:flutter/material.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/pages/center_support_page.dart';
import 'package:foodapp/pages/payment_detail_page.dart';
import 'package:foodapp/pages/rating_page.dart';
import 'package:foodapp/pages/services_order.dart';
import 'package:foodapp/components/review_dialog.dart';
import 'package:intl/intl.dart';
import '../data/model/request.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/model/requestdetail.dart';
import '../data/repository/repository.dart';
import 'helper_detail_page.dart';

class OrderDetailPage extends StatefulWidget {
  final Requests request;
  final List<Helper> helpers;
  final List<Services> services;
  final Customer customer;
  final String token;
  final String refreshToken;
  final String deviceToken;
  final RequestDetail requestDetail;

  const OrderDetailPage({
    super.key,
    required this.request,
    required this.helpers,
    required this.services,
    required this.customer,
    required this.token,
    required this.refreshToken,
    required this.deviceToken,
    required this.requestDetail,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late List<RequestDetail>? requestDetailData = [];
  final List<Helper> requestHelpers = [];
  bool isLoading = true;
  double promotion = 5000;
  bool hasReviewed = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
    loadRequestDetailData(widget.request);
  }

  Future<void> loadRequestDetailData(Requests request) async {
    setState(() {
      isLoading = true;
    });

    var repository = DefaultRepository();
    if (request.scheduleIds.isNotEmpty) {
      var data = await repository.loadRequestDetailId(
          request.scheduleIds, widget.token);
      setState(() {
        requestDetailData = data ?? [];
        isLoading = false;
      });

      // Load helper information
      for (var data in requestDetailData!) {
        try {
          var requestHelper =
              widget.helpers.firstWhere((helper) => helper.id == data.helperID);
          requestHelpers.add(requestHelper);
        } catch (e) {
          print('Helper not found for ID: ${data.helperID}');
        }
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    double roundedAmount = amount.roundToDouble();
    return "${formatter.format(roundedAmount)} đ";
  }

  String _formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat("EEEE, dd 'Tháng' MM, yyyy - HH:mm", "vi_VN")
        .format(dateTime);
  }

  // Xóa map hình ảnh minh họa (có thể comment hoặc xóa)
  // final Map<String, String> _timelineImages = {
  //   'ordered': 'assets/timeline/ordered.png',
  //   'assigned': 'assets/timeline/assigned.png',
  //   'inProgress': 'assets/timeline/inprogress.png',
  //   'waitPayment': 'assets/timeline/waitpayment.png',
  //   'completed': 'assets/timeline/completed.png',
  //   'cancelled': 'assets/timeline/cancelled.png',
  // };

  // Add this map for timeline icons
  final Map<String, IconData> _timelineIcons = {
    'ordered': Icons.shopping_cart,
    'assigned': Icons.verified_user,
    'inProgress': Icons.hourglass_top,
    'waitPayment': Icons.payment,
    'completed': Icons.check_circle,
    'cancelled': Icons.cancel,
  };

  @override
  Widget build(BuildContext context) {
    print('ngày bắt đầu: ${widget.request.schedules.first.startTime}');
    print(_formatDate(widget.request.startTime));
    print('trạng thái: ${widget.request.status}');
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Quicksand',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderStatusCard(),
                      const SizedBox(height: 16),
                      _buildTimelineView(),
                      const SizedBox(height: 16),
                      // _buildCustomerInfoCard(),
                      // const SizedBox(height: 16),
                      if (requestHelpers.isNotEmpty) _buildHelperInfoCard(),
                      if (requestHelpers.isNotEmpty) const SizedBox(height: 16),
                      _buildServiceDetailsCard(),
                      const SizedBox(height: 16),
                      _buildPaymentDetailsCard(),
                      const SizedBox(height: 16),
                      _buildSupportAndFeedbackCard(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildOrderStatusCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã đơn hàng - flexible layout
          LayoutBuilder(
            builder: (context, constraints) {
              // Kiểm tra nếu màn hình nhỏ (< 350px width)
              bool isSmallScreen = constraints.maxWidth < 350;

              if (isSmallScreen) {
                // Layout dọc cho màn hình nhỏ
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mã đơn hàng:',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Quicksand',
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '#823482342',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                  ],
                );
              } else {
                // Layout ngang cho màn hình lớn
                return Row(
                  children: [
                    Text(
                      'Mã đơn hàng: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Quicksand',
                        fontSize: 15,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '#823482342',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Quicksand',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 8),
          // Ngày đặt - flexible layout
          LayoutBuilder(
            builder: (context, constraints) {
              bool isSmallScreen = constraints.maxWidth < 350;

              if (isSmallScreen) {
                // Layout dọc cho màn hình nhỏ
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Đặt lúc:',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_formatDate(widget.request.oderDate)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Quicksand',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              } else {
                // Layout ngang cho màn hình lớn với wrap
                return Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Đặt lúc: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            constraints.maxWidth - 80, // Trừ đi width của label
                      ),
                      child: Text(
                        '${_formatDate(widget.request.oderDate)}',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    String orderStatus = widget.request.status;

    final steps = [
      {'title': 'Đã đặt đơn', 'key': 'ordered'},
      {'title': 'Đã xác nhận', 'key': 'assigned'},
      {'title': 'Đang thực hiện', 'key': 'inProgress'},
      {'title': 'Chờ thanh toán', 'key': 'waitPayment'},
      {'title': 'Đã hoàn thành', 'key': 'completed'},
    ];

    int activeStep = 0;
    switch (orderStatus) {
      case 'ordered':
        activeStep = 0;
        break;
      case 'assigned':
        activeStep = 1;
        break;
      case 'inProgress':
        activeStep = 2;
        break;
      case 'waitPayment':
        activeStep = 3;
        break;
      case 'completed':
        activeStep = 4;
        break;
      case 'cancelled':
        activeStep = -1;
        break;
      default:
        activeStep = 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trạng thái đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
            ),
          ),
          const SizedBox(height: 16),
          if (orderStatus != 'cancelled') ...[
            // Normal timeline
            for (int i = 0; i < steps.length; i++)
              _buildTimelineItem(
                title: steps[i]['title']!,
                time: i == 0
                    ? _formatDate(widget.request.oderDate)
                    : (i <= activeStep ? 'Hoàn thành' : 'Đang chờ'),
                isActive: i <= activeStep,
                isFirst: i == 0,
                isLast: i == steps.length - 1,
                iconData: _timelineIcons[steps[i]['key']!]!,
              ),
          ] else ...[
            // Cancelled timeline
            _buildTimelineItem(
              title: 'Đã đặt đơn',
              time: _formatDate(widget.request.oderDate),
              isActive: true,
              isFirst: true,
              iconData: _timelineIcons['ordered']!,
            ),
            _buildTimelineItem(
              title: 'Đơn bị huỷ',
              time: 'Đã huỷ',
              isActive: true,
              isLast: true,
              isCancelled: true,
              iconData: _timelineIcons['cancelled']!,
            ),
          ],
        ],
      ),
    );
  }

  // Sửa hàm _buildTimelineItem: bỏ imagePath, bỏ widget Image.asset
  Widget _buildTimelineItem({
    required String title,
    required String time,
    required bool isActive,
    bool isFirst = false,
    bool isLast = false,
    bool isCancelled = false,
    required IconData iconData,
  }) {
    Color circleColor = isCancelled
        ? Colors.red
        : (isActive ? Colors.green : Colors.grey.shade300);
    Color borderColor = isCancelled
        ? Colors.red.shade100
        : (isActive ? Colors.green.shade100 : Colors.white);
    Color lineColor = isCancelled
        ? Colors.red
        : (isActive ? Colors.green : Colors.grey.shade300);
    Color titleColor =
        isCancelled ? Colors.red : (isActive ? Colors.black : Colors.grey);
    Color timeColor =
        isCancelled ? Colors.red : (isActive ? Colors.green : Colors.grey);

    double iconScale = (isActive || isCancelled) ? 1.2 : 1.0;
    double opacity = isActive || isCancelled ? 1.0 : 0.7;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: opacity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: 3,
                    ),
                    boxShadow: [
                      if (isActive || isCancelled)
                        BoxShadow(
                          color: circleColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: AnimatedScale(
                    scale: iconScale,
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      iconData,
                      color:
                          isActive || isCancelled ? Colors.white : Colors.grey,
                      size: 16,
                    ),
                  ),
                ),
                if (!isLast)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    width: 2,
                    height: 40,
                    color: lineColor,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.05)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  if (isActive)
                    BoxShadow(
                      color: Colors.green.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                      fontFamily: 'Quicksand',
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    style: TextStyle(
                      fontSize: 13,
                      color: timeColor,
                      fontFamily: 'Quicksand',
                    ),
                    child: Text(time),
                  ),
                  SizedBox(height: isLast ? 0 : 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCustomerInfoCard() {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(Icons.person_rounded, color: Colors.green.shade600),
  //             const SizedBox(width: 8),
  //             const Text(
  //               'Thông tin khách hàng',
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //                 fontFamily: 'Quicksand',
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Divider(height: 24),
  //         Row(
  //           children: [
  //             CircleAvatar(
  //               radius: 24,
  //               backgroundColor: Colors.green.shade50,
  //               child: Icon(Icons.person_outline,
  //                   color: Colors.green.shade600, size: 28),
  //             ),
  //             const SizedBox(width: 16),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     widget.request.customerInfo.fullName,
  //                     style: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                       fontFamily: 'Quicksand',
  //                     ),
  //                   ),
  //                   const SizedBox(height: 6),
  //                   Row(
  //                     children: [
  //                       Icon(Icons.phone_android,
  //                           color: Colors.grey.shade600, size: 16),
  //                       const SizedBox(width: 6),
  //                       Text(
  //                         widget.request.customerInfo.phone,
  //                         style: TextStyle(
  //                           color: Colors.grey.shade700,
  //                           fontFamily: 'Quicksand',
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Row(
  //                     children: [
  //                       Icon(Icons.location_on,
  //                           color: Colors.grey.shade600, size: 16),
  //                       const SizedBox(width: 6),
  //                       Expanded(
  //                         child: Text(
  //                           widget.request.customerInfo.address,
  //                           style: TextStyle(
  //                             color: Colors.grey.shade700,
  //                             fontFamily: 'Quicksand',
  //                           ),
  //                           maxLines: 2,
  //                           overflow: TextOverflow.ellipsis,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHelperInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cleaning_services_rounded,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              const Text(
                'Thông tin người giúp việc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: Colors.grey.shade300,
          ),
          ...requestHelpers.map(
            (helper) => Column(
              children: [
                // CircleAvatar(
                //   backgroundColor: const Color(0xFFE8F5E9),
                //   radius: 50,
                //   child: requestHelpers.first.avatar != null &&
                //           requestHelpers.isNotEmpty
                //       ? ClipRRect(
                //           borderRadius: BorderRadius.circular(50),
                //           child: Image.network(
                //             requestHelpers.first.avatar!,
                //             fit: BoxFit.cover,
                //             height: 100,
                //             width: 100,
                //           ),
                //         )
                //       : Icon(Icons.person, color: Colors.green),
                // ),
                Hero(
                  tag: 'helper_avatar_${helper.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: helper.avatar?.isNotEmpty == true
                          ? NetworkImage(helper.avatar!)
                          : null,
                      child: helper.avatar?.isNotEmpty != true
                          ? Icon(Icons.person,
                              size: 45, color: Colors.grey[400])
                          : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 6),

                            Text(
                              // helper.fullName,
                              '${requestHelpers.first.fullName}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            // const SizedBox(height: 4),
                            // Text(
                            //   // helper.phone,
                            //   '${requestHelpers.first.yearOfExperience} kinh nghiệm',

                            //   style: TextStyle(
                            //     color: Colors.grey.shade700,
                            //     fontFamily: 'Quicksand',
                            //   ),
                            // ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "26 lượt đánh giá",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "5",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontFamily: 'Quicksand',
                                  ),
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HelperDetailPage(
                                          helper: helper,
                                          services: widget.services,
                                          token: widget.token,
                                          refreshToken: widget.refreshToken,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.insert_drive_file_outlined,
                                    size: 16,
                                    color: Colors.green,
                                  ),
                                  label: Text(
                                    'Thông tin',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade50,
                                    foregroundColor: Colors.green,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.message_outlined,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  label: const Text(
                                    'Nhắn tin',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Quicksand',
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết dịch vụ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: Colors.grey.shade300,
          ),
          _buildServiceDetailItem(
            icon: Icons.cleaning_services_rounded,
            title: widget.request.service.title,
            subtitle: 'Loại dịch vụ',
          ),
          const SizedBox(height: 16),
          _buildServiceDetailItem(
            icon: Icons.location_on_rounded,
            title: widget.request.customerInfo.address,
            subtitle:
                '${widget.request.location.ward}, ${widget.request.location.province}',
          ),
          const SizedBox(height: 16),
          _buildServiceDetailItem(
            icon: Icons.calendar_today_rounded,
            title: _formatDate(widget.request.startTime),
            subtitle: 'Thời gian bắt đầu',
          ),
          const SizedBox(height: 16),
          _buildServiceDetailItem(
            icon: Icons.access_time_rounded,
            title: _formatDate(widget.request.endTime),
            subtitle: 'Thời gian hoàn thành dịch vụ',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.green, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Quicksand',
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontFamily: 'Quicksand',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text(
                'Chi tiết thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
              ),
            ],
          ),
          Divider(
            height: 24,
            color: Colors.grey.shade300,
          ),
          _buildPaymentRow(
            'Chi phí dịch vụ',
            _formatCurrency(widget.request.totalCost.toDouble()),
          ),
          // const SizedBox(height: 12),
          // _buildPaymentRow(
          //   'Khuyến mãi',
          //   '- ${_formatCurrency(promotion)}',
          //   valueColor: Colors.red,
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200),
          ),
          _buildPaymentRow(
            'Tổng thanh toán',
            _formatCurrency(widget.request.totalCost.toDouble()),
            isTotal: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngân hàng VCB',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                            Text(
                              'Thanh toán thành công',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 12,
                                fontFamily: 'Quicksand',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.green.shade50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailPage(),
                    ),
                  );
                },
                child: const Text(
                  'Chi tiết',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value,
      {bool isTotal = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
            fontFamily: 'Quicksand',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? (isTotal ? Colors.green : Colors.grey[600]),
            fontFamily: 'Quicksand',
          ),
        ),
      ],
    );
  }

  Widget _buildSupportAndFeedbackCard() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportCenterPage(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.support_agent, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  const Text(
                    'Hỗ trợ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RatingHelperPage(
                      helper: requestHelpers.first,
                      detailId: widget.requestDetail.id,
                      token: widget.token,
                      refreshToken: widget.refreshToken,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_outlined, color: Colors.amber.shade600),
                  const SizedBox(width: 12),
                  const Text(
                    'Báo cáo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!hasReviewed && widget.request.status == 'completed') ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ReviewDialog.show(
                    context: context,
                    requestId: widget.requestDetail.id,
                    token: widget.token,
                    onReviewSubmitted: () {
                      setState(() {
                        hasReviewed = true;
                      });
                    },
                  );
                },
                icon: const Icon(
                  Icons.feedback,
                  color: Colors.green,
                ),
                label: const Text(
                  'Đánh giá',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Quicksand',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade700),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                var matchingServices = widget.services
                    .where((service) =>
                        widget.request.service.title == service.title)
                    .toList();

                Services reorderService = matchingServices.isNotEmpty
                    ? matchingServices.first
                    : widget.services[0];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServicesOrder(
                      customer: widget.customer,
                      service: reorderService,
                      services: widget.services,
                      token: widget.token,
                      refreshToken: widget.refreshToken,
                      deviceToken: widget.deviceToken,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: const Text(
                'Đặt lại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Quicksand',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
