import 'package:flutter/material.dart';
import 'package:foodapp/components/my_button.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/request.dart';
import '../data/model/customer.dart';
import 'package:foodapp/pages/helper_list_page.dart';
import '../data/model/service.dart';

class CustomCalendar extends StatefulWidget {
  final List<DateTime> initialSelectedDates;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Customer customer;
  final Requests request;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final Services service;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const CustomCalendar({
    Key? key,
    this.initialSelectedDates = const [],
    this.minDate,
    this.maxDate,
    required this.customer,
    required this.request,
    required this.costFactors,
    required this.services,
    required this.service,
    required this.token,
    required this.refreshToken,
    required this.deviceToken,
  }) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDate = DateTime.now();
  late List<DateTime> _selectedDates;
  late int _selectedMonth;
  late int _selectedYear;
  late PageController _pageController;
  bool _isWeekView = false;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initialSelectedDates;

    if (_selectedDates.isNotEmpty) {
      _focusedDate = _selectedDates.first;
    }

    _selectedMonth = _focusedDate.month;
    _selectedYear = _focusedDate.year;
    _pageController =
        PageController(initialPage: _calculatePageIndex(_focusedDate));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Existing methods remain the same (calculatePageIndex, calculateDateFromPageIndex, etc.)
  int _calculatePageIndex(DateTime date) {
    return (date.year * 12 + date.month) -
        (DateTime(2000, 1).year * 12 + DateTime(2000, 1).month);
  }

  DateTime _calculateDateFromPageIndex(int pageIndex) {
    final baseDate = DateTime(2000, 1);
    return DateTime(baseDate.year + pageIndex ~/ 12, pageIndex % 12 + 1);
  }

  List<DateTime?> _generateDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    int leadingDays = (firstDayOfMonth.weekday - 1) % 7;

    List<DateTime?> days = List.generate(
      lastDayOfMonth.day,
      (index) => DateTime(date.year, date.month, index + 1),
    );

    for (int i = 0; i < leadingDays; i++) {
      days.insert(0, null);
    }

    return days;
  }

  bool _isDateInRange(DateTime date) {
    final minDate = widget.minDate;
    final maxDate = widget.maxDate;

    if (minDate != null && date.isBefore(minDate)) return false;
    if (maxDate != null && date.isAfter(maxDate)) return false;
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1))))
      return false;

    return true;
  }

  void _toggleDateSelection(DateTime date) {
    if (!_isDateInRange(date)) return;

    setState(() {
      if (_selectedDates.length <= 2 && _selectedDates.contains(date)) {
        return;
      }

      if (_selectedDates.contains(date)) {
        _selectedDates.remove(date);
      } else {
        _selectedDates.add(date);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ Nhật'
    ];
    // final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: Text(
          'Chọn ngày',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isWeekView ? Icons.calendar_today : Icons.view_week,
              // color: colorScheme.onPrimary,
            ),
            onPressed: () {
              setState(() {
                _isWeekView = !_isWeekView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdownWithLabel(
                  value: _selectedMonth,
                  items: List.generate(12, (index) => index + 1),
                  label: 'Tháng',
                  onChanged: (newMonth) {
                    if (newMonth != null) {
                      final newDate = DateTime(_selectedYear, newMonth, 1);
                      final newPageIndex = _calculatePageIndex(newDate);
                      _pageController.jumpToPage(newPageIndex);
                    }
                  },
                ),
                _buildDropdownWithLabel(
                  value: _selectedYear,
                  items: List.generate(
                      30, (index) => DateTime.now().year - 15 + index),
                  label: 'Năm',
                  onChanged: (newYear) {
                    if (newYear != null) {
                      final newDate = DateTime(newYear, _selectedMonth, 1);
                      final newPageIndex = _calculatePageIndex(newDate);
                      _pageController.jumpToPage(newPageIndex);
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (pageIndex) {
                final newDate = _calculateDateFromPageIndex(pageIndex);
                setState(() {
                  _focusedDate = newDate;
                  _selectedMonth = newDate.month;
                  _selectedYear = newDate.year;
                });
              },
              itemBuilder: (context, pageIndex) {
                final date = _calculateDateFromPageIndex(pageIndex);
                final days = _generateDaysInMonth(date);

                return Column(
                  children: [
                    _buildWeekdayHeader(weekdays),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: days.length,
                        itemBuilder: (context, index) {
                          final day = days[index];
                          return day == null
                              ? const SizedBox.shrink()
                              : _buildCalendarDay(day);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MyButton(
              text: 'Xác nhận',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HelperList(
                      customer: widget.customer,
                      request: widget.request,
                      listDate: _selectedDates,
                      isOnDemand: false,
                      costFactors: widget.costFactors,
                      services: widget.services,
                      service: widget.service,
                      token: widget.token,
                      refreshToken: widget.refreshToken,
                      deviceToken: widget.deviceToken,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownWithLabel({
    required int value,
    required List<int> items,
    required String label,
    required void Function(int?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Quicksand',
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButton<int>(
          value: value,
          dropdownColor: Colors.white,
          underline: Container(
            height: 2,
            color: Colors.green,
          ),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      "$item",
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(List<String> weekdays) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: weekdays.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day) {
    final isSelected = _selectedDates.contains(day);
    final isInRange = _isDateInRange(day);

    return GestureDetector(
      onTap: () => _toggleDateSelection(day),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[500] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green[200]!.withOpacity(0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          day.day.toString(),
          style: TextStyle(
            color: isInRange
                ? (isSelected ? Colors.white : Colors.black87)
                : Colors.grey,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontFamily: 'Quicksand',
          ),
        ),
      ),
    );
  }
}
