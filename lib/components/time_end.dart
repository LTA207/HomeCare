import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeEnd extends StatefulWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final TimeOfDay? startTime;

  const TimeEnd({
    super.key,
    this.initialTime,
    required this.onTimeChanged,
    this.startTime,
  });

  @override
  State<TimeEnd> createState() => _TimeEndState();
}

class _TimeEndState extends State<TimeEnd> {
  TimeOfDay? _selectedTime;

  // Tạo danh sách các thời gian cách nhau 30 phút cho thời gian kết thúc
  List<TimeOfDay> _generateEndTimeSlots() {
    List<TimeOfDay> timeSlots = [];

    if (widget.startTime == null) {
      return timeSlots;
    }

    final startTime = widget.startTime!;

    // Tính thời gian tối thiểu (startTime + 2 giờ)
    int minHour = startTime.hour + 2;
    int minMinute = startTime.minute;

    // Điều chỉnh nếu vượt quá 60 phút
    if (minMinute >= 60) {
      minHour += minMinute ~/ 60;
      minMinute = minMinute % 60;
    }

    // Làm tròn lên khung thời gian 30 phút gần nhất
    if (minMinute > 0 && minMinute <= 30) {
      minMinute = 30;
    } else if (minMinute > 30) {
      minHour += 1;
      minMinute = 0;
    }

    // Tạo các khung thời gian từ thời gian tối thiểu đến 20:00
    for (int hour = minHour; hour <= 20; hour++) {
      if (hour == minHour) {
        // Bắt đầu từ phút tối thiểu
        if (minMinute == 0) {
          timeSlots.add(TimeOfDay(hour: hour, minute: 0));
          if (hour < 20) timeSlots.add(TimeOfDay(hour: hour, minute: 30));
        } else if (minMinute == 30) {
          timeSlots.add(TimeOfDay(hour: hour, minute: 30));
        }
      } else if (hour < 20) {
        timeSlots.add(TimeOfDay(hour: hour, minute: 0));
        timeSlots.add(TimeOfDay(hour: hour, minute: 30));
      } else {
        // Chỉ thêm 20:00
        timeSlots.add(TimeOfDay(hour: hour, minute: 0));
      }
    }

    return timeSlots;
  }

  @override
  void initState() {
    super.initState();
    _updateInitialTime();
  }

  @override
  void didUpdateWidget(covariant TimeEnd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime) {
      _updateInitialTime();
    }
  }

  void _updateInitialTime() {
    final startTime = widget.startTime;

    if (startTime != null) {
      int endHour = startTime.hour + 2;
      int endMinute = startTime.minute;

      // Làm tròn lên khung 30 phút gần nhất
      if (endMinute > 0 && endMinute <= 30) {
        endMinute = 30;
      } else if (endMinute > 30) {
        endHour += 1;
        endMinute = 0;
      }

      _selectedTime = widget.initialTime ?? TimeOfDay(hour: endHour, minute: endMinute);
    } else {
      _selectedTime = null;
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat('HH:mm');
    return format.format(dt);
  }

  Future<void> _selectTime(BuildContext context) async {
    if (widget.startTime == null) {
      showPopUpWarning('Chọn thời gian bắt đầu trước');
      return;
    }

    List<TimeOfDay> availableTimes = _generateEndTimeSlots();

    if (availableTimes.isEmpty) {
      showPopUpWarning('Không có thời gian khả dụng');
      return;
    }

    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chọn thời gian kết thúc',
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

  bool _isTimeInValidRange(TimeOfDay time) {
    final now = DateTime.now();
    final selectedTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final startOfValidRange =
        DateTime(now.year, now.month, now.day, 6, 0); // 6h sáng
    final endOfValidRange =
        DateTime(now.year, now.month, now.day, 20, 1); // 8h tối

    return selectedTime.isAfter(startOfValidRange) &&
        selectedTime.isBefore(endOfValidRange);
  }

  bool _isEndTimeValid(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes - startMinutes >= 120; // ít nhất 2 giờ (120 phút)
  }

  void showPopUpWarning(String warning) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      showCloseIcon: true,
      title: 'Warning',
      desc: warning,
      btnCancelOnPress: () {},
      btnOkOnPress: () {},
    ).show();
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
                Icon(
                  Icons.timelapse_rounded,
                  color: Colors.green.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
