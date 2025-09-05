import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodapp/components/Confirm_day.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/pages/order_detail_longterm_page.dart';
import 'package:foodapp/pages/order_detail_page.dart';
import 'package:foodapp/pages/payment_page.dart';
import 'package:foodapp/pages/services_order.dart';
import 'package:foodapp/services/firebase_messaging_service.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:web_socket_channel/io.dart';

import '../data/model/customer.dart';
import '../data/model/requestdetail.dart';
import '../data/model/service.dart';
import '../data/repository/repository.dart';

class ActivityPage extends StatefulWidget {
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final String token;
  final String refreshToken;

  const ActivityPage({
    Key? key,
    required this.customer,
    required this.costFactors,
    required this.services,
    required this.token,
    required this.refreshToken,
  }) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Requests> requests = [];
  List<RequestDetail> requestDetails = [];
  List<Requests>? requestCustomer = [];
  List<RequestDetail>? requestDetailCustomer = [];
  List<Helper>? helperList = [];
  bool isLoading = true;
  Key pageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    loadAllData();

    _tabController = TabController(length: 2, vsync: this);

    // Đăng ký callback để lắng nghe thông báo Firebase
    FirebaseMessagingService.setDataChangeCallback(() {
      print('🔔 Nhận thông báo, đang refresh data...');
      _refreshData();
    });
  }

  @override
  void dispose() {
    // Hủy đăng ký callback khi dispose
    FirebaseMessagingService.clearDataChangeCallback();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadHelperData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCleanerData();
    // Chỉ cập nhật data, không setState ở đây
    helperList = data ?? [];
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

  Future<void> loadRequestDetailData() async {
    var repository = DefaultRepository();
    var data = await repository.loadRequestDetail(widget.token);
    // Chỉ cập nhật data, không setState ở đây
    requestDetails = data ?? [];
    print('đã tải lại request detail data');
  }

  // Hàm load tất cả data và chỉ setState một lần duy nhất
  Future<void> loadAllData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Chạy song song để tăng tốc độ
      await Future.wait([
        loadHelperData(),
        loadRequestData(),
        loadRequestDetailData(),
      ]);
    } catch (e) {
      print('❌ Lỗi khi tải data: $e');
    }

    // Chỉ setState một lần duy nhất sau khi tất cả data đã được tải
    setState(() {
      isLoading = false;
      pageKey = UniqueKey();
      print('✅ Đã tải xong tất cả dữ liệu');
    });
  }

  String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    int roundedAmount = amount.round();
    return "${formatter.format(roundedAmount)} đ";
  }

  int selectedIndex = 0;

  void _onTabSelected(int index) {
    if (selectedIndex == index) return;

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        selectedIndex = index;
        isLoading = false;
      });
    });
  }

  Future<void> _refreshData() async {
    // Gọi trực tiếp loadAllData() thay vì setState rồi gọi loadAllData
    await loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Text(
          'Hoạt động',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            padding:
                const EdgeInsets.all(4), // Padding giúp có hiệu ứng tròn hơn
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabButton(0, "Theo ngày"),
                _buildTabButton(1, "Dài hạn"),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: Container(
            key: pageKey,
            child: isLoading
                ? Center(
                    key: const ValueKey('loading'),
                    child: Lottie.asset(
                      'lib/images/loading.json',
                      width: 100,
                      height: 100,
                      repeat: true,
                    ),
                  )
                : selectedIndex == 0
                    ? OnDemand(
                        requests: requestCustomer ?? [],
                        key: const ValueKey('on_demand'),
                        customer: widget.customer,
                        costFactors: widget.costFactors,
                        services: widget.services,
                        helperList: helperList!,
                        requestDetail: requestDetails,
                        refreshData: loadRequestData,
                        token: widget.token,
                        refreshToken: widget.refreshToken,
                      )
                    : LongTerm(
                        requests: requestCustomer ?? [],
                        key: const ValueKey('long_term'),
                        customer: widget.customer,
                        costFactors: widget.costFactors,
                        services: widget.services,
                        helperList: helperList!,
                        refreshData: loadRequestData,
                        requestDetail: requestDetails,
                        token: widget.token,
                        refreshToken: widget.refreshToken,
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.green,
              fontWeight: FontWeight.bold,
              fontFamily: 'Quicksand',
              fontSize: isSelected ? 16 : 14,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

class OnDemand extends StatefulWidget {
  final List<Requests> requests;
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final List<Helper> helperList;
  final List<RequestDetail> requestDetail;
  final Future<void> Function() refreshData;
  final String token;
  final String refreshToken;

  const OnDemand({
    super.key,
    required this.requests,
    required this.customer,
    required this.costFactors,
    required this.services,
    required this.helperList,
    required this.refreshData,
    required this.requestDetail,
    required this.token,
    required this.refreshToken,
  });

  @override
  State<OnDemand> createState() => _OnDemandState();
}

class _OnDemandState extends State<OnDemand> {
  late Map<String, List<Requests>> groupedRequests;

  // Map<String, List<RequestDetail>> groupedDetails = {};

  @override
  void initState() {
    super.initState();
    groupedRequests = {};

    List<Requests> shortTermRequests = widget.requests
        .where((request) => request.requestType == 'Ngắn hạn')
        .toList();

    // Sắp xếp danh sách theo orderDate giảm dần
    shortTermRequests.sort((a, b) =>
        DateTime.parse(b.oderDate).compareTo(DateTime.parse(a.oderDate)));

    // List<RequestDetail> shortTermDetails = widget.requestDetail
    //     .where((reqDetail) => shortTermRequests
    //         .map((request) => request.scheduleIds.first)
    //         .contains(reqDetail.id))
    //     .toList();

    for (var request in shortTermRequests) {
      String date =
          DateFormat('dd-MM-yyyy').format(DateTime.parse(request.oderDate));

      // groupedDetails[request.id] = shortTermDetails
      //     .where((reqDetail) => reqDetail.id == request.scheduleIds.first)
      //     .toList();

      if (groupedRequests.containsKey(date)) {
        groupedRequests[date]!.add(request);
      } else {
        groupedRequests[date] = [request];
      }
    }
  }

  String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    int roundedAmount = amount.round();
    return "${formatter.format(roundedAmount)} đ";
  }

  Color _getStatusBackgroundColor(String status) {
    switch (status) {
      case 'pending':
        // return Color(0xFFE5FEDF); // Xanh nhạt
        return Colors.red;
      case 'assigned':
        return Color(0xFFFFF3CD); // Vàng nhạt
      case 'inProgress':
        return Color(0xFFD1ECF1); // Xanh dương nhạt
      case 'waitPayment':
        return Color(0xFFFFD600); // Nâu nhạt
      case 'completed':
        return Color(0xFFD4EDDA); // Xanh lá cây nhạt
      case 'cancelled':
        return Color(0xFFF8D7DA); // Đỏ nhạt
      default:
        return Colors.red;
    }
  }

  String getStatusInVietnamese(String status) {
    switch (status) {
      case "pending":
        return "Chưa tiến hành";
      case "assigned":
        return "Đã giao việc";
      case "waitPayment":
        return "Chờ thanh toán";
      case "completed":
        return "Đã hoàn thành";
      case "inProgress":
        return "Đang tiến hành";
      case "cancelled":
        return "Đã huỷ";
      default:
        return "Không xác định";
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'pending':
        // return Color(0xFF2FA559); // Xanh lá cây
        return Colors.white;
      case 'assigned':
        return Color(0xFF856404); // Vàng đậm
      case 'inProgress':
        return Color(0xFF0C5460); // Xanh dương đậm
      case 'completed':
        return Color(0xFF155724); // Xanh lá cây đậm
      case 'cancelled':
        return Color(0xFF721C24); // Đỏ đậm
      default:
        return Colors.white; // Mặc định màu đen
    }
  }

  void showCancelConfirmationDialog(BuildContext context, Requests request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cancel Dialog",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => Container(),
      transitionBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon cảnh báo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tiêu đề
                    const Text(
                      "Xác nhận huỷ yêu cầu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Nội dung thông báo
                    const Text(
                      "Bạn có chắc chắn muốn huỷ yêu cầu này? Hành động này không thể hoàn tác.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Quicksand',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nút bấm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Hủy
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Không",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nút Xác nhận
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _cancelRequest(request);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Có, huỷ ngay",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, Requests request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Xác nhận",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Xác nhận người giúp việc đã hoàn thành việc và thanh toán ${formatCurrency(request.totalCost.toDouble())} cho người giúp việc?",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Không",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                // Navigator.pop(context);
                // // _showPaymentDialog(context, request);
                // _doneRequest(request);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentPage(
                      amount: request.totalCost,
                      // Tổng chi phí
                      customer: widget.customer,
                      costFactors: widget.costFactors,
                      services: widget.services,
                      requestDetail: request.schedules.first,
                      token: widget.token,
                      refreshToken: widget.refreshToken,
                    ),
                  ),
                );
              },
              child: Text(
                "Xác nhận",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelRequest(Requests request) {
    var repository = DefaultRepository();
    repository.canceledRequest(request.id);
    setState(() {
      request.status = "cancelled";
    });
  }

  @override
  Widget build(BuildContext context) {
    print('danh sách: ${groupedRequests}');
    return Container(
      color: const Color(0xFFF5F5F5),
      child: groupedRequests.isEmpty
          ? const Center(
              child: Text(
                "Không có yêu cầu ngắn hạn",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: groupedRequests.length,
              itemBuilder: (context, index) {
                final entry = groupedRequests.entries.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...entry.value.map((request) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ngày thực hiện: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(request.startTime))}',
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand',
                                      color: Color(0xFF5B6366),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: _getStatusBackgroundColor(
                                          request.schedules.first.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(
                                      getStatusInVietnamese(
                                          request.schedules.first.status),
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        color:
                                            _getStatusTextColor(request.status),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.cleaning_services_rounded,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                request.service.title,
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                // '${request.totalCost}₫',
                                                formatCurrency(request.totalCost
                                                    .toDouble()),
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${request.customerInfo.address}, ${request.location.district}, ${request.location.province}',
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // InkWell(
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => OrderDetailPage(
                                  //           request: request,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   child: const Text(
                                  //     "Chi tiết",
                                  //     style: TextStyle(
                                  //       fontFamily: 'Quicksand',
                                  //       fontSize: 14,
                                  //       color: Colors.green,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  // ),
                                  // (groupedDetails[request.id]?.isNotEmpty ??
                                  //             false) &&
                                  request.schedules.first.status == "pending"
                                      ? ElevatedButton(
                                          onPressed: () {
                                            showCancelConfirmationDialog(
                                                context, request);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[100],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            "Huỷ yêu cầu",
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      : request.status == 'waitPayment'
                                          ? ElevatedButton(
                                              onPressed: () {
                                                _showConfirmationDialog(
                                                    context, request);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "Thanh toán",
                                                style: TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : request.schedules.first.status ==
                                                  'inProgress'
                                              ? Container()
                                              : request.schedules.first
                                                          .status ==
                                                      'assigned'
                                                  ? Container()
                                                  : ElevatedButton(
                                                      onPressed: () {
                                                        var matchingServices =
                                                            widget.services
                                                                .where((service) =>
                                                                    request
                                                                        .service
                                                                        .title ==
                                                                    service
                                                                        .title)
                                                                .toList();

                                                        Services
                                                            reorderService =
                                                            matchingServices
                                                                    .isNotEmpty
                                                                ? matchingServices
                                                                    .first
                                                                : widget
                                                                    .services[0];
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ServicesOrder(
                                                              customer: widget
                                                                  .customer,
                                                              service:
                                                                  reorderService,
                                                              costFactors: widget
                                                                  .costFactors,
                                                              services: widget
                                                                  .services,
                                                              token:
                                                                  widget.token,
                                                              refreshToken: widget
                                                                  .refreshToken,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.grey[300],
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        "Đặt lại",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Quicksand',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderDetailPage(
                                            request: request,
                                            helpers: widget.helperList,
                                            services: widget.services,
                                            customer: widget.customer,
                                            costFactors: widget.costFactors,
                                            token: widget.token,
                                            refreshToken: widget.refreshToken,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Xem chi tiết",
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}

class LongTerm extends StatefulWidget {
  final List<Requests> requests;
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final List<Helper> helperList;
  final List<RequestDetail> requestDetail;
  final Future<void> Function() refreshData;
  final String token;
  final String refreshToken;

  const LongTerm(
      {super.key,
      required this.requests,
      required this.customer,
      required this.costFactors,
      required this.services,
      required this.helperList,
      required this.refreshData,
      required this.requestDetail,
      required this.token,
      required this.refreshToken});

  @override
  State<LongTerm> createState() => _LongTermState();
}

class _LongTermState extends State<LongTerm> {
  Map<String, List<Requests>> groupedRequests = {};
  Map<String, List<RequestDetail>> groupedDetails = {};

  @override
  void initState() {
    super.initState();

    List<Requests> longTermRequests = widget.requests
        .where((request) => request.requestType == 'Dài hạn')
        .toList();

    longTermRequests.sort((a, b) =>
        DateTime.parse(b.oderDate).compareTo(DateTime.parse(a.oderDate)));

    Map<String, List<RequestDetail>> detailsByScheduleId = {};

    // for (var reqDetail in widget.requestDetail) {
    //   for (var request in longTermRequests) {
    //     for (var scheduleId in request.scheduleIds) {
    //       if (reqDetail.id == scheduleId) {
    //         if (!detailsByScheduleId.containsKey(request.id)) {
    //           detailsByScheduleId[request.id] = [];
    //         }
    //         detailsByScheduleId[request.id]!.addAll(request.schedules);
    //       }
    //     }
    //   }
    // }

    for (var request in longTermRequests) {
      if (!detailsByScheduleId.containsKey(request.id)) {
        detailsByScheduleId[request.id] = [];
      }
      detailsByScheduleId[request.id]!.addAll(request.schedules);
    }

    for (var request in longTermRequests) {
      String startDate =
          DateFormat('dd-MM-yyyy').format(DateTime.parse(request.oderDate));

      var matchedRequestDetails = detailsByScheduleId[request.id] ?? [];

      if (matchedRequestDetails.isNotEmpty) {
        groupedDetails[request.id] = matchedRequestDetails;
      }

      if (groupedRequests.containsKey(startDate)) {
        groupedRequests[startDate]!.add(request);
      } else {
        groupedRequests[startDate] = [request];
      }
    }
  }

  String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    int roundedAmount = amount.round();
    return "${formatter.format(roundedAmount)} đ";
  }

  String getStatusInVietnamese(String status) {
    switch (status) {
      case "pending":
        return "Chưa tiến hành";
      case "assigned":
        return "Đã giao việc";
      case "completed":
        return "Đã hoàn thành";
      case "inProgress":
        return "Đang tiến hành";
      case "cancelled":
        return "Đã huỷ";
      default:
        return "Không xác định";
    }
  }

  void showCancelConfirmationDialog(BuildContext context, Requests request) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cancel Dialog",
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => Container(),
      transitionBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon cảnh báo
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tiêu đề
                    const Text(
                      "Xác nhận huỷ yêu cầu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Nội dung thông báo
                    const Text(
                      "Bạn có chắc chắn muốn huỷ yêu cầu này? Hành động này không thể hoàn tác.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Quicksand',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nút bấm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút Hủy
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Không",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Nút Xác nhận
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _cancelRequest(request);
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Có, huỷ ngay",
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _cancelRequest(Requests request) {
    setState(() {
      request.status = "cancelled";
    });
  }

  @override
  Widget build(BuildContext context) {
    print(groupedDetails);
    return Container(
      color: const Color(0xFFF5F5F5),
      child: groupedRequests.isEmpty
          ? const Center(
              child: Text(
                "Không có yêu cầu dài hạn",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: groupedRequests.length,
              itemBuilder: (context, index) {
                final entry = groupedRequests.entries.elementAt(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          entry.key, // Ngày bắt đầu
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...entry.value.map((request) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Từ: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(request.startTime))}',
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand',
                                      color: Color(0xFF5B6366),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Đến: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(request.endTime))}',
                                    style: const TextStyle(
                                      fontFamily: 'Quicksand',
                                      color: Color(0xFF5B6366),
                                      fontSize: 14,
                                    ),
                                  ),

                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     color: _getStatusBackgroundColor(
                                  //       request.status,
                                  //     ),
                                  //     borderRadius: BorderRadius.circular(8),
                                  //   ),
                                  //   padding: const EdgeInsets.symmetric(
                                  //     horizontal: 8,
                                  //     vertical: 4,
                                  //   ),
                                  //   child: Text(
                                  //     getStatusInVietnamese(
                                  //       request.status,
                                  //     ),
                                  //     style: TextStyle(
                                  //       fontFamily: 'Quicksand',
                                  //       color:
                                  //           _getStatusTextColor(request.status),
                                  //       fontSize: 14,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.cleaning_services_rounded,
                                      color: Colors.green,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                request.service.title,
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                // '${request.totalCost}₫',
                                                formatCurrency(request.totalCost
                                                    .toDouble()),
                                                style: const TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          request.customerInfo.address,
                                          style: const TextStyle(
                                            fontFamily: 'Quicksand',
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // InkWell(
                                  //   onTap: () {
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //         builder: (context) => OrderDetailPage(
                                  //           request: request,
                                  //         ),
                                  //       ),
                                  //     );
                                  //   },
                                  //   child: const Text(
                                  //     "Chi tiết",
                                  //     style: TextStyle(
                                  //       fontFamily: 'Quicksand',
                                  //       fontSize: 14,
                                  //       color: Colors.green,
                                  //       fontWeight: FontWeight.bold,
                                  //     ),
                                  //   ),
                                  // ),

                                  (request.status == "pending")
                                      ? ElevatedButton(
                                          onPressed: () {
                                            showCancelConfirmationDialog(
                                                context, request);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[100],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            "Huỷ yêu cầu",
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      : request.status == 'inProgress'
                                          ? ElevatedButton(
                                              onPressed: () {
                                                print(request.scheduleIds);
                                                showConfirmLongTermDayDialog(
                                                  context,
                                                  request,
                                                  widget.customer,
                                                  widget.costFactors,
                                                  widget.services,
                                                  widget.token,
                                                  widget.refreshToken,
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Text(
                                                "Thanh toán",
                                                style: TextStyle(
                                                  fontFamily: 'Quicksand',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : request.status == 'assigned'
                                              ? Container()
                                              : ElevatedButton(
                                                  onPressed: () {
                                                    var matchingServices =
                                                        widget.services
                                                            .where((service) =>
                                                                request.service
                                                                    .title ==
                                                                service.title)
                                                            .toList();

                                                    Services reorderService =
                                                        matchingServices
                                                                .isNotEmpty
                                                            ? matchingServices
                                                                .first
                                                            : widget
                                                                .services[0];
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ServicesOrder(
                                                          customer:
                                                              widget.customer,
                                                          service:
                                                              reorderService,
                                                          costFactors: widget
                                                              .costFactors,
                                                          services:
                                                              widget.services,
                                                          selectedTab: 1,
                                                          token: widget.token,
                                                          refreshToken: widget
                                                              .refreshToken,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey.shade300,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Đặt lại",
                                                    style: TextStyle(
                                                      fontFamily: 'Quicksand',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderDetailLongTermPage(
                                            request: request,
                                            helpers: widget.helperList,
                                            services: widget.services,
                                            costFactors: widget.costFactors,
                                            customer: widget.customer,
                                            requestDetail:
                                                groupedDetails[request.id] ??
                                                    [],
                                            token: widget.token,
                                            refreshToken: widget.refreshToken,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      "Xem chi tiết",
                                      style: TextStyle(
                                        fontFamily: 'Quicksand',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
    );
  }
}
