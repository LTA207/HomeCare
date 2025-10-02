import 'package:flutter/material.dart';
import 'package:foodapp/components/time_selection.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/coefficient.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/pages/long_term_calendar_selection_page.dart';
import 'package:intl/intl.dart';

import '../../data/model/customer.dart';
import '../../data/model/location.dart';
import '../../data/repository/repository.dart';
import '../components/city_selected.dart';
import '../components/my_button.dart';
import '../components/warning_dialog.dart';
import '../data/model/service.dart';
import 'helper_list_page.dart';

class ServicesOrder extends StatefulWidget {
  final Customer customer;
  final Services service;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final int selectedTab; // Thêm tham số
  final String token;
  final String refreshToken;
  final String deviceToken;

  const ServicesOrder({
    super.key,
    required this.customer,
    required this.service,
    required this.costFactors,
    required this.services,
    this.selectedTab = 0, required this.token, required this.refreshToken, required this.deviceToken, // Mặc định là tab 0 (Theo ngày)
  });

  @override
  State<ServicesOrder> createState() => _ServicesOrderState();
}

class _ServicesOrderState extends State<ServicesOrder>
    with SingleTickerProviderStateMixin {
  // late TabController _tabController;
  List<Location> locations = [];
  List<Customer> customers = [];
  List<CoefficientOther>? coefficientService = [];
  num basicCoefficient = 0;
  bool isLoading = true;
  String orderType = 'Ngắn hạn';
  DateTime? selectedDate;
  DateTime? startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? endDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(const Duration(days: 1));
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Location? selectedProvince;
  String? selectedWard;
  String? selectedDetailedAddress;

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

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedTab;
    loadData();
  }

  Future<void> loadData() async {
    var repository = DefaultRepository();
    var dataLocation = await repository.loadLocation();
    var dataCustomer = await repository.loadCustomer('');
    var dataCoefficient = await repository.loadCoefficientService();
    if (mounted) {
      setState(() {
        locations = dataLocation ?? [];
        customers = dataCustomer ?? [];
        coefficientService = dataCoefficient ?? [];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String formatCurrency(double amount) {
    final NumberFormat formatter = NumberFormat("#,###", "vi_VN");
    int roundedAmount = amount.round();
    return "${formatter.format(roundedAmount)} đ";
  }

  @override
  Widget build(BuildContext context) {
    if (coefficientService!.isNotEmpty) {
      final coefficientList = coefficientService!.first.coefficientList;
      final coefficient = coefficientList.firstWhere(
        (coefficientId) => coefficientId.id == widget.service.coefficientId,
        orElse: () => coefficientList.isNotEmpty
            ? coefficientList.first
            : Coefficient(id: '', value: 1.0, title: '', description: '', deleted: false, status: ''),
      );
      basicCoefficient = coefficient.value;
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.green,
        title: Text(
          widget.service.title,
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              size: 28,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Thông tin dịch vụ ${widget.service.title}',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mô tả dịch vụ
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Mô tả dịch vụ:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            widget.service.description,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        // Phí dịch vụ
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Phí dịch vụ:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(width: 8),
                        Text(
                          formatCurrency(widget.service.basicPrice.toDouble()),
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        // automaticallyImplyLeading: false,
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 1000),
        child: selectedIndex == 0
            ? OnDemand(
                locations: locations,
                customer: widget.customer,
                onVisibilityChanged: (isVisible) {
                  if (!isVisible) {
                    setState(() {
                      endDate = null;
                    });
                    print(endDate);
                  }
                },
                onTimeChanged: (startTime, endTime) {
                  setState(() {
                    _startTime = startTime;
                    if (endTime == null && startTime != null) {
                      _endTime = TimeOfDay(
                          hour: _startTime!.hour + 2,
                          minute: _startTime!.minute);
                    } else {
                      _endTime = endTime;
                    }
                  });
                },
                onDateChanged: (date, isStartDate) {
                  setState(() {
                    if (isStartDate == 'start') {
                      selectedDate = date;
                      startDate = date;
                      endDate = null;
                    }
                  });
                },
                onProvinceSelected: (Location province) {
                  setState(() {
                    selectedProvince = province;
                  });
                  print(province);
                },
                onWardSelected: (String ward) {
                  setState(() {
                    selectedWard = ward;
                  });
                },
                onDetailedAddressChanged: (String detailedAddress) {
                  setState(() {
                    selectedDetailedAddress = detailedAddress;
                  });
                  print(detailedAddress);
                },
              )
            : LongTerm(
                locations: locations,
                customer: widget.customer,
                onVisibilityChanged: (isVisible) {
                  if (isVisible) {
                    setState(() {
                      endDate = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day)
                          .add(const Duration(days: 1));
                    });
                    print(endDate);
                  }
                },
                onTimeChanged: (startTime, endTime) {
                  setState(() {
                    _startTime = startTime;
                    if (endTime == null && startTime != null) {
                      _endTime = TimeOfDay(
                          hour: _startTime!.hour + 2,
                          minute: _startTime!.minute);
                    } else {
                      _endTime = endTime;
                    }
                  });
                },
                onDateChanged: (date, isStartDate) {
                  setState(() {
                    if (isStartDate == 'start') {
                      selectedDate = date;
                      startDate = date;
                    } else {
                      endDate = date;
                      orderType = 'Dài hạn';
                    }
                  });
                },
                onProvinceSelected: (Location province) {
                  setState(() {
                    selectedProvince = province;
                  });
                },
                onWardSelected: (String ward) {
                  setState(() {
                    selectedWard = ward;
                  });
                },
                onDetailedAddressChanged: (String detailedAddress) {
                  setState(() {
                    selectedDetailedAddress = detailedAddress;
                  });
                  print(selectedDetailedAddress);
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: MyButton(
          text: "Tiếp theo",
          onTap: () {
            selectedDate ??= DateTime.now();
            DateTime? selectedEndDate = endDate ?? selectedDate;

            // Kiểm tra nếu startTime là thời điểm trong quá khứ
            DateTime selectedStartDateTime = DateTime(
              selectedDate!.year,
              selectedDate!.month,
              selectedDate!.day,
              _startTime?.hour ?? 0,
              _startTime?.minute ?? 0,
            );

            DateTime now = DateTime.now();

            if (selectedStartDateTime.isBefore(now)) {
              showPopUpWarning(context,
                  "Thời gian bắt đầu không thể ở quá khứ. Vui lòng chọn ngày khác!");
              return; // Dừng xử lý nếu thời gian không hợp lệ
            }

            if (endDate != null &&
                endDate?.day == selectedStartDateTime.day &&
                endDate?.month == selectedStartDateTime.month &&
                endDate?.year == selectedStartDateTime.year) {
              showPopUpWarning(
                  context, "Ngày bắt đầu và kết thúc không được trùng nhau");
              return;
            }

            if (endDate != null && startDate!.isAfter(endDate!)) {
              showPopUpWarning(
                  context, 'Ngày bắt đầu phải trước ngày kết thúc');
              return;
            }

            // Kiểm tra xem người dùng có chọn địa chỉ mới không
            bool isNewAddressSelected = selectedProvince != null &&
                selectedWard != null &&
                selectedDetailedAddress != null &&
                selectedProvince!.name != widget.customer.addresses[0].province;

            if (isNewAddressSelected) {
              var newAddress = Addresses(
                province: selectedProvince!.name,
                ward: selectedWard!,
                detailedAddress: selectedDetailedAddress!,
              );
              widget.customer.addresses.add(newAddress);
            }

            // Xác định địa chỉ cuối cùng của khách hàng
            String finalAddress = isNewAddressSelected
                ? widget.customer.addresses.last
                    .toString() // Địa chỉ mới nếu đã chọn
                : widget.customer.addresses[0]
                    .detailedAddress; // Địa chỉ cũ nếu không thay đổi

            if (_startTime == null || _endTime == null) {
              showPopUpWarning(
                  context, 'Vui lòng chọn thời gian bắt đầu và kết thúc');
              return;
            }
            // Create a Request object
            var request = Requests(
              customerInfo: CustomerInfo(
                  fullName: widget.customer.name,
                  phone: widget.customer.phone,
                  address: finalAddress,
                  usedPoint: widget.customer.points[0].point),
              service: RequestService(
                  title: widget.service.title,
                  coefficientService: 1.0,
                  coefficientOther: 1.0,
                  cost: widget.service.basicPrice),
              location: (selectedProvince != null &&
                      selectedWard != null &&
                      selectedDetailedAddress != null)
                  ? RequestLocation(
                      province: selectedProvince!.name,
                      ward: selectedWard!,
                    )
                  : RequestLocation(
                      province: widget.customer.addresses[0].province,
                      ward: widget.customer.addresses[0].ward),
              id: '',
              // Generate or provide an ID if required
              oderDate: DateTime.now().toIso8601String(),
              scheduleIds: [],
              // Add any schedule IDs if needed
              startDate: DateFormat('yyyy-MM-dd').format(DateTime(
                  selectedDate!.year, selectedDate!.month, selectedDate!.day)),
              startTime: DateTime(selectedDate!.year, selectedDate!.month,
                      selectedDate!.day, _startTime!.hour, _startTime!.minute)
                  .toIso8601String(),
              endTime: DateTime(selectedEndDate!.year, selectedEndDate.month,
                      selectedEndDate.day, _endTime!.hour, _endTime!.minute)
                  .toIso8601String(),
              requestType: endDate != null ? 'Dài hạn' : 'Ngắn hạn',
              // Set based on your application's logic
              totalCost: 0,
              // Calculate or set the total cost
              status: 'notDone',
              // Set the initial status
              deleted: false,
              comment:
                  Comment(review: '', loseThings: false, breakThings: false),
              profit: 0,
              schedules: [],
            );
            print('Request Information:');
            print('Customer Name: ${request.customerInfo.fullName}');
            print('Customer Phone: ${request.customerInfo.phone}');
            print('Customer Address: ${request.customerInfo.address}');
            print('Service Title: ${request.service.title}');
            print('Start Date: ${request.startDate}');
            print('Start Time: ${request.startTime}');
            print('End Time: ${request.endTime}');
            print(
                'Location: ${request.location.province}, ${request.location.ward}');
            print('Order Date: ${request.oderDate}');
            print('Request Type: ${request.requestType}');
            print('Total Cost: ${request.totalCost}');
            print('Status: ${request.status}');

            if (selectedIndex == 0) {
              request.endTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      _endTime!.hour,
                      _endTime!.minute)
                  .toIso8601String();
              print('End Time: ${request.endTime}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HelperList(
                    customer: widget.customer,
                    request: request,
                    listDate: List.generate(1, (index) => startDate!),
                    isOnDemand: true,
                    costFactors: widget.costFactors,
                    services: widget.services,
                    service: widget.service,
                    token: widget.token,
                    refreshToken: widget.refreshToken,
                    deviceToken: widget.deviceToken,
                  ),
                ),
              );
            } else {
              startDate =
                  DateTime(startDate!.year, startDate!.month, startDate!.day);
              endDate = DateTime(endDate!.year, endDate!.month, endDate!.day);
              print(List.generate(
                endDate!.difference(startDate!).inDays + 1, // Số ngày cần tạo
                (index) => DateTime(startDate!.year, startDate!.month,
                    startDate!.day + index), // Chỉ lấy ngày/tháng/năm
              ));
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomCalendar(
                    initialSelectedDates: List.generate(
                      endDate!.difference(startDate!).inDays + 1,
                      // Số ngày cần tạo
                      (index) => DateTime(startDate!.year, startDate!.month,
                          startDate!.day + index), // Chỉ lấy ngày/tháng/năm
                    ),
                    customer: widget.customer,
                    request: request,
                    maxDate:
                        DateTime(endDate!.year, endDate!.month, endDate!.day),
                    minDate: DateTime(
                        startDate!.year, startDate!.month, startDate!.day),
                    costFactors: widget.costFactors,
                    services: widget.services,
                    service: widget.service,
                    // minDate: DateTime(2025, 2, 25),
                    // maxDate: DateTime(2025, 2, 26),
                    token: widget.token,
                    refreshToken: widget.refreshToken,
                    deviceToken: widget.deviceToken,
                  ),
                ),
              );
            }
          },
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
  final List<Location> locations;
  final Customer customer;
  final Function(TimeOfDay?, TimeOfDay?)? onTimeChanged;
  final Function(Location)? onProvinceSelected;
  final Function(String)? onWardSelected;
  final Function(DateTime?, String?)? onDateChanged;
  final Function(String)? onDetailedAddressChanged;
  final Function(bool)? onVisibilityChanged;

  const OnDemand({
    super.key,
    required this.locations,
    required this.customer,
    this.onTimeChanged,
    this.onProvinceSelected,
    this.onWardSelected,
    this.onDateChanged,
    this.onDetailedAddressChanged,
    this.onVisibilityChanged,
  });

  @override
  State<OnDemand> createState() => _OnDemandState();
}

class _OnDemandState extends State<OnDemand> {
  Location? selectedProvince;
  String? selectedWard;
  String? selectedDetailedAddress;
  bool isEditingLocation = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chọn thời gian
            TimeSelection(
              onTimeChanged: widget.onTimeChanged,
              onDateChanged: widget.onDateChanged,
              onVisibilityChanged: widget.onVisibilityChanged,
              isOnDemand: true,
            ),
            const SizedBox(height: 20),

            // // Hiển thị tiêu đề "Địa điểm"
            // const Text("Địa điểm",
            //     style: TextStyle(
            //         fontFamily: 'Quicksand',
            //         fontWeight: FontWeight.w600,
            //         fontSize: 16)),
            // const SizedBox(height: 5),

            // Hiển thị địa chỉ hiện tại + Button Edit
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Địa điểm',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0.0, 1.0),
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4.0,
                          spreadRadius: 0.0,
                        )
                      ],
                    ),
                    child: ListTile(
                      // leading: const Icon(Icons.location_on_outlined,
                      //     color: Colors.green),
                      title: Text(
                        selectedProvince != null &&
                                selectedWard != null &&
                                selectedDetailedAddress != null
                            ? "$selectedDetailedAddress, $selectedWard, ${selectedProvince!.name}"
                            : (widget.customer.addresses.isNotEmpty
                                ? widget.customer.addresses[0].toString()
                                : "Chưa có địa chỉ"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isEditingLocation ? Icons.expand_less : Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              isEditingLocation = !isEditingLocation;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Khi nhấn edit thì hiện SelectLocation + Nhập địa chỉ chi tiết
                  if (isEditingLocation)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SelectLocation(
                            locations: widget.locations,
                            onProvinceSelected: (province) {
                              setState(() {
                                selectedProvince = province;
                              });
                              if (widget.onProvinceSelected != null) {
                                widget.onProvinceSelected!(province);
                              }
                            },
                            onWardSelected: (ward) {
                              setState(() {
                                selectedWard = ward;
                              });
                              if (widget.onWardSelected != null) {
                                widget.onWardSelected!(ward);
                              }
                            },
                            onAddressChanged: (detailedAddress) {
                              setState(() {
                                selectedDetailedAddress = detailedAddress;
                              });
                              if (widget.onDetailedAddressChanged != null) {
                                widget
                                    .onDetailedAddressChanged!(detailedAddress);
                              }
                            },
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
    );
  }
}

class LongTerm extends StatefulWidget {
  final List<Location> locations;
  final Customer customer;
  final Function(TimeOfDay?, TimeOfDay?)? onTimeChanged;
  final Function(Location)? onProvinceSelected;
  final Function(String)? onWardSelected;
  final Function(DateTime?, String?)? onDateChanged;
  final Function(String)? onDetailedAddressChanged;
  final Function(bool)? onVisibilityChanged;

  const LongTerm(
      {super.key,
      required this.locations,
      this.onTimeChanged,
      this.onProvinceSelected,
      this.onDateChanged,
      this.onWardSelected,
      this.onDetailedAddressChanged,
      required this.customer,
      this.onVisibilityChanged});

  @override
  State<LongTerm> createState() => _LongTermState();
}

class _LongTermState extends State<LongTerm> {
  Location? selectedProvince;
  String? selectedWard;
  String? selectedDetailedAddress;
  bool isEditingLocation = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Thời gian",
            //   style: TextStyle(
            //     fontFamily: 'Quicksand',
            //     fontWeight: FontWeight.w600,
            //     // color: Colors.green,
            //     fontSize: 16,
            //   ),
            // ),
            // const SizedBox(height: 5),
            // const SizedBox(height: 20),
            // const Text(
            //   "Giờ bắt đầu",
            //   style: TextStyle(
            //     fontFamily: 'Quicksand',
            //     fontWeight: FontWeight.w600,
            //     fontSize: 16,
            //   ),
            // ),
            TimeSelection(
              onTimeChanged: widget.onTimeChanged,
              onDateChanged: widget.onDateChanged,
              onVisibilityChanged: widget.onVisibilityChanged,
              isOnDemand: false,
            ),
            const SizedBox(height: 20),
            // const Text(
            //   "Địa điểm",
            //   style: TextStyle(
            //     fontFamily: 'Quicksand',
            //     fontWeight: FontWeight.w600,
            //     // color: Colors.green,
            //     fontSize: 16,
            //   ),
            // ),
            // const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      'Địa điểm',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0.0, 1.0),
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4.0,
                          spreadRadius: 0.0,
                        )
                      ],
                    ),
                    child: ListTile(
                      // leading: const Icon(Icons.location_on_outlined,
                      //     color: Colors.green),
                      title: Text(
                        selectedProvince != null &&
                                selectedWard != null &&
                                selectedDetailedAddress != null
                            ? "$selectedDetailedAddress, $selectedWard, ${selectedProvince!.name}"
                            : (widget.customer.addresses.isNotEmpty
                                ? widget.customer.addresses[0].toString()
                                : "Chưa có địa chỉ"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isEditingLocation ? Icons.expand_less : Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              isEditingLocation = !isEditingLocation;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Khi nhấn edit thì hiện SelectLocation + Nhập địa chỉ chi tiết
                  if (isEditingLocation)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SelectLocation(
                            locations: widget.locations,
                            onProvinceSelected: (province) {
                              setState(() {
                                selectedProvince = province;
                              });
                              if (widget.onProvinceSelected != null) {
                                widget.onProvinceSelected!(province);
                              }
                            },
                            onWardSelected: (ward) {
                              setState(() {
                                selectedWard = ward;
                              });
                              if (widget.onWardSelected != null) {
                                widget.onWardSelected!(ward);
                              }
                            },
                            onAddressChanged: (detailedAddress) {
                              setState(() {
                                selectedDetailedAddress = detailedAddress;
                              });
                              if (widget.onDetailedAddressChanged != null) {
                                widget
                                    .onDetailedAddressChanged!(detailedAddress);
                              }
                            },
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
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:foodapp/components/address_type.dart';
// import 'package:foodapp/components/time_selection.dart';
// import 'package:foodapp/data/model/CostFactor.dart';
// import 'package:foodapp/data/model/request.dart';
// import 'package:foodapp/pages/long_term_calendar_selection_page.dart';
// import 'package:intl/intl.dart';

// import '../../data/model/customer.dart';
// import '../../data/model/location.dart';
// import '../../data/repository/repository.dart';
// import '../components/city_selected.dart';
// import '../components/my_button.dart';
// import '../data/model/service.dart';
// import 'helper_list_page.dart';

// class ServicesOrder extends StatefulWidget {
//   final Customer customer;
//   final Services service;
//   final List<CostFactor> costFactors;
//   final List<Services> services;

//   const ServicesOrder({
//     super.key,
//     required this.customer,
//     required this.service,
//     required this.costFactors,
//     required this.services,
//   });

//   @override
//   State<ServicesOrder> createState() => _ServicesOrderState();
// }

// class _ServicesOrderState extends State<ServicesOrder>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<Location> locations = [];
//   List<Customer> customers = [];
//   bool isLoading = true;
//   String orderType = 'Ngắn hạn';
//   DateTime? selectedDate;
//   DateTime? startDate =
//       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//   DateTime? endDate =
//       DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
//           .add(const Duration(days: 1));
//   TimeOfDay? _startTime;
//   TimeOfDay? _endTime;
//   Location? selectedProvince;
//   String? selectedDistrict;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     loadData();
//   }

//   Future<void> loadData() async {
//     var repository = DefaultRepository();
//     var dataLocation = await repository.loadLocation();
//     var dataCustomer = await repository.loadCustomer();
//     setState(() {
//       locations = dataLocation ?? [];
//       customers = dataCustomer ?? [];
//       isLoading = false;
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _handleNextStep() {
//     selectedDate ??= DateTime.now();
//     DateTime? selectedEndDate = endDate ?? selectedDate;

//     if (_startTime != null && _endTime != null) {
//       var request = Requests(
//         customerInfo: CustomerInfo(
//           fullName: widget.customer.name,
//           phone: widget.customer.phone,
//           address: widget.customer.addresses[0].detailedAddress,
//           usedPoint: widget.customer.points[0].point,
//         ),
//         service: RequestService(
//           title: widget.service.title,
//           coefficientService: 0.0,
//           coefficientOther: 0.0,
//           cost: widget.service.basicPrice,
//         ),
//         location: selectedProvince != null
//             ? RequestLocation(
//                 province: selectedProvince!.name,
//                 district: selectedDistrict ?? '',
//               )
//             : RequestLocation(province: '', district: ''),
//         id: '',
//         oderDate: DateTime.now().toIso8601String(),
//         scheduleIds: [],
//         startDate: DateFormat('yyyy-MM-dd').format(selectedDate!),
//         startTime: DateTime(
//           selectedDate!.year,
//           selectedDate!.month,
//           selectedDate!.day,
//           _startTime!.hour,
//           _startTime!.minute,
//         ).toIso8601String(),
//         endTime: DateTime(
//           selectedEndDate!.year,
//           selectedEndDate.month,
//           selectedEndDate.day,
//           _endTime!.hour,
//           _endTime!.minute,
//         ).toIso8601String(),
//         requestType: orderType,
//         totalCost: 0,
//         status: 'chưa tiến hành',
//         deleted: false,
//         comment: Comment(review: '', loseThings: false, breakThings: false),
//         profit: 0,
//       );

//       if (_tabController.index == 0) {
//         request.endTime = DateTime(
//           selectedDate!.year,
//           selectedDate!.month,
//           selectedDate!.day,
//           _endTime!.hour,
//           _endTime!.minute,
//         ).toIso8601String();

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => HelperList(
//               customer: widget.customer,
//               request: request,
//               listDate: List.generate(1, (index) => startDate!),
//               isOnDemand: true,
//               costFactors: widget.costFactors,
//               services: widget.services,
//             ),
//           ),
//         );
//       } else {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CustomCalendar(
//               initialSelectedDates: List.generate(
//                 endDate!.difference(startDate!).inDays + 1,
//                 (index) => startDate!.add(Duration(days: index)),
//               ),
//               customer: widget.customer,
//               request: request,
//               maxDate: endDate,
//               minDate: startDate,
//               costFactors: widget.costFactors,
//               services: widget.services,
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 110,
//             pinned: true,
//             floating: false,
//             backgroundColor: Colors.green,
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.green, Colors.lightGreen],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 46),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           // Chỗ này thay 0 theo index là được
//                           'Dịch vụ: ${widget.services[0].title}',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Quicksand',
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   )),
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(48),
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 ),
//                 child: TabBar(
//                   controller: _tabController,
//                   labelColor: Colors.green,
//                   unselectedLabelColor: Colors.black54,
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   indicator: const UnderlineTabIndicator(
//                     borderSide: BorderSide(color: Colors.green, width: 3),
//                   ),
//                   tabs: const [
//                     Tab(text: 'Theo ngày'),
//                     Tab(text: 'Dài hạn'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SliverFillRemaining(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 ServiceOrderTab(
//                   isOnDemand: true,
//                   locations: locations,
//                   customers: customers,
//                   onTimeChanged: (startTime, endTime) {
//                     setState(() {
//                       _startTime = startTime;
//                       if (endTime == null && startTime != null) {
//                         _endTime = TimeOfDay(
//                           hour: _startTime!.hour + 2,
//                           minute: _startTime!.minute,
//                         );
//                       } else {
//                         _endTime = endTime;
//                       }
//                     });
//                   },
//                   onDateChanged: (date, isStartDate) {
//                     setState(() {
//                       if (isStartDate == 'start') {
//                         selectedDate = date;
//                         startDate = date;
//                         endDate = null;
//                       }
//                     });
//                   },
//                   onProvinceSelected: (Location province) {
//                     setState(() {
//                       selectedProvince = province;
//                     });
//                   },
//                   onWardSelected: (String ward) {
//                     setState(() {
//                       selectedWard = ward;
//                     });
//                   },
//                 ),
//                 ServiceOrderTab(
//                   isOnDemand: false,
//                   locations: locations,
//                   customers: customers,
//                   onTimeChanged: (startTime, endTime) {
//                     setState(() {
//                       _startTime = startTime;
//                       if (endTime == null && startTime != null) {
//                         _endTime = TimeOfDay(
//                           hour: _startTime!.hour + 2,
//                           minute: _startTime!.minute,
//                         );
//                       } else {
//                         _endTime = endTime;
//                       }
//                     });
//                   },
//                   onDateChanged: (date, isStartDate) {
//                     setState(() {
//                       if (isStartDate == 'start') {
//                         selectedDate = date;
//                         startDate = date;
//                       } else {
//                         endDate = date;
//                         orderType = 'Dài hạn';
//                       }
//                     });
//                   },
//                   onProvinceSelected: (Location province) {
//                     setState(() {
//                       selectedProvince = province;
//                     });
//                   },
//                   onWardSelected: (String ward) {
//                     setState(() {
//                       selectedWard = ward;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: ElevatedButton(
//             onPressed: _handleNextStep,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             child: const Text(
//               'Tiếp theo',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Quicksand',
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ServiceOrderTab extends StatefulWidget {
//   final bool isOnDemand;
//   final List<Location> locations;
//   final List<Customer> customers;
//   final Function(TimeOfDay?, TimeOfDay?)? onTimeChanged;
//   final Function(Location)? onProvinceSelected;
//   final Function(String)? onWardSelected;
//   final Function(DateTime?, String?)? onDateChanged;

//   const ServiceOrderTab({
//     super.key,
//     required this.isOnDemand,
//     required this.locations,
//     required this.customers,
//     this.onTimeChanged,
//     this.onProvinceSelected,
//     this.onWardSelected,
//     this.onDateChanged,
//   });

//   @override
//   State<ServiceOrderTab> createState() => _ServiceOrderTabState();
// }

// class _ServiceOrderTabState extends State<ServiceOrderTab> {
//   Location? selectedProvince;
//   String? selectedWard;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Thời gian",
//               style: TextStyle(
//                 fontFamily: 'Quicksand',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 24),
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: TimeSelection(
//                   onTimeChanged: widget.onTimeChanged,
//                   onDateChanged: widget.onDateChanged,
//                   isOnDemand: widget.isOnDemand,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               "Địa điểm",
//               style: TextStyle(
//                 fontFamily: 'Quicksand',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     SelectLocation(
//                       locations: widget.locations,
//                       onProvinceSelected: (Location province) {
//                         setState(() {
//                           selectedProvince = province;
//                         });
//                         widget.onProvinceSelected?.call(province);
//                       },
//                       onWardSelected: (String ward) {
//                         setState(() {
//                           selectedWard = ward;
//                         });
//                         widget.onWardSelected?.call(ward);
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     const AddressType(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
