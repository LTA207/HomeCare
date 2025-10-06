// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
//
// class TestPageSyncfusion extends StatefulWidget {
//   @override
//   _TestPageSyncfusionState createState() => _TestPageSyncfusionState();
// }
//
// class _TestPageSyncfusionState extends State<TestPageSyncfusion> {
//   DateTime? selectedDate;
//
//   void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
//     setState(() {
//       selectedDate = args.value;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Syncfusion Date Picker Test"),
//         backgroundColor: Colors.green,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               selectedDate != null
//                   ? "Ngày đã chọn: ${selectedDate!.toLocal().toString().split(' ')[0]}"
//                   : "Chưa chọn ngày nào",
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SfDateRangePicker(
//               view: DateRangePickerView.month,
//               selectionMode: DateRangePickerSelectionMode.single,
//               onSelectionChanged: _onSelectionChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
