import 'package:flutter/material.dart';
import 'package:foodapp/components/warning_dialog.dart';
import 'package:intl/intl.dart';

class TimeStart extends StatefulWidget {
  final DateTime? date;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TimeStart({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
    this.date,
  });

  @override
  State<TimeStart> createState() => _TimeStartState();
}

class _TimeStartState extends State<TimeStart> {
  TimeOfDay? _selectedTime;
  DateTime referenceDate = DateTime.now();

  // Tạo danh sách các thời gian cách nhau 30 phút
  List<TimeOfDay> _generateTimeSlots() {
    List<TimeOfDay> timeSlots = [];
    final now = DateTime.now();
    bool isSameDay = referenceDate.year == now.year &&
        referenceDate.month == now.month &&
        referenceDate.day == now.day;

    int startHour = 6;
    int endHour = 18; // Thay đổi từ isSameDay ? 15 : 18 thành 18

    for (int hour = startHour; hour < endHour; hour++) {
      timeSlots.add(TimeOfDay(hour: hour, minute: 0));
      timeSlots.add(TimeOfDay(hour: hour, minute: 30));
    }

    // Thêm thời gian cuối cùng (18:00)
    timeSlots.add(TimeOfDay(hour: endHour, minute: 0));

    // Lọc các thời gian hợp lệ cho ngày hôm nay
    if (isSameDay) {
      timeSlots = timeSlots.where((time) {
        DateTime selectedDateTime = referenceDate.copyWith(
          hour: time.hour,
          minute: time.minute,
        );
        return selectedDateTime.isAfter(now);
      }).toList();
    }

    return timeSlots;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    referenceDate = widget.date ?? now;

    // Khởi tạo thời gian nếu có thời gian khởi tạo
    if (widget.initialTime != null) {
      _selectedTime = widget.initialTime;
    } else {
      if (referenceDate.hour >= 18 && referenceDate.day == now.day) { // Thay đổi từ 15 thành 18
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showPopUpWarning(context,
              'Thời gian hiện tại đã qua 18:00. Vui lòng chọn ngày khác'); // Thay đổi từ 15:00 thành 18:00
        });
      } else if (referenceDate.hour >= 6 && referenceDate.hour < 18) { // Thay đổi từ 15 thành 18
        int additionalHours = referenceDate.minute > 30 ? 4 : 3;
        int selectedHour = referenceDate.hour + additionalHours;
        // Làm tròn thời gian về khung 30 phút gần nhất
        _selectedTime = TimeOfDay(hour: selectedHour, minute: 0);
      } else {
        _selectedTime = null;
      }
    }

    // Gọi onTimeChanged ngay khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedTime != null) {
        widget.onTimeChanged(_selectedTime!);
      }
    });
  }

  @override
  void didUpdateWidget(TimeStart oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Kiểm tra xem ngày đã thay đổi chưa
    if (widget.date != oldWidget.date) {
      // Cập nhật lại referenceDate và _selectedTime khi date thay đổi
      referenceDate = widget.date ?? DateTime.now();
      if (referenceDate.hour >= 6 && referenceDate.hour < 17) { // Thay đổi từ 14 thành 17
        int additionalHours = referenceDate.minute > 30 ? 4 : 3;
        _selectedTime = TimeOfDay(
          hour: referenceDate.hour + additionalHours,
          minute: 0,
        );
      } else {
        _selectedTime = widget.initialTime;
      }
      // Gọi lại onTimeChanged để thông báo sự thay đổi
      if (_selectedTime != null) {
        widget.onTimeChanged(_selectedTime!);
      }
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    referenceDate = widget.date ?? DateTime.now();
    final dt = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
      time.hour,
      time.minute,
    );
    final format = DateFormat('HH:mm');
    return format.format(dt);
  }

  Future<void> _selectTime(BuildContext context) async {
    final now = DateTime.now();

    bool isSameDay = referenceDate.year == now.year &&
        referenceDate.month == now.month &&
        referenceDate.day == now.day;

    // Kiểm tra điều kiện thời gian cho ngày hôm nay
    if (isSameDay && now.hour >= 18) { // Thay đổi từ 15 thành 18
      showPopUpWarning(context,
          'Thời gian hiện tại đã qua 18:00. Vui lòng chọn ngày khác'); // Thay đổi từ 15:00 thành 18:00
      return;
    }

    List<TimeOfDay> availableTimes = _generateTimeSlots();

    if (availableTimes.isEmpty) {
      showPopUpWarning(context, 'Không có thời gian khả dụng cho ngày này');
      return;
    }

    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chọn thời gian',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: availableTimes.length,
              itemBuilder: (context, index) {
                final time = availableTimes[index];
                final isSelected = _selectedTime != null &&
                    _selectedTime!.hour == time.hour &&
                    _selectedTime!.minute == time.minute;

                return ListTile(
                  title: Text(
                    formatTimeOfDay(time),
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.green : Colors.black,
                    ),
                  ),
                  leading: Radio<TimeOfDay>(
                    value: time,
                    groupValue: _selectedTime,
                    onChanged: (TimeOfDay? value) {
                      Navigator.of(context).pop(value);
                    },
                    activeColor: Colors.green,
                  ),
                  onTap: () {
                    Navigator.of(context).pop(time);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        widget.onTimeChanged(_selectedTime!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            _selectTime(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  offset: Offset(0.0, 1.0),
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4.0,
                  spreadRadius: 0.0,
                )
              ],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime != null
                      ? formatTimeOfDay(_selectedTime!)
                      : 'Chọn thời gian bắt đầu',
                  style: _selectedTime != null
                      ? TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        )
                      : TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                ),
                const Icon(
                  Icons.timelapse_rounded,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
