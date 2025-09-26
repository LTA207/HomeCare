import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/data/model/requestdetail.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/data/repository/repository.dart';
import 'package:foodapp/pages/payment_page.dart';
import 'package:intl/intl.dart';

import '../data/model/customer.dart';

class ConfirmLongTermDay extends StatefulWidget {
  final Requests requests;
  final Customer customer;
  final List<CostFactor> costFactors;
  final List<Services> services;
  final String token;
  final String refreshToken;

  const ConfirmLongTermDay(
      {super.key,
      required this.requests,
      required this.customer,
      required this.costFactors,
      required this.services,
      required this.token,
      required this.refreshToken});

  @override
  State<ConfirmLongTermDay> createState() => _ConfirmLongTermDayState();
}

class _ConfirmLongTermDayState extends State<ConfirmLongTermDay> {
  List<RequestDetail>? requestDetailList;
  bool isAllFinish = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var repository = DefaultRepository();
    var data =
        await repository.loadRequestDetailId(widget.requests.scheduleIds, widget.token);
    setState(() {
      requestDetailList = data ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentDate = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "Xác nhận hoàn thành",
              style: TextStyle(
                fontSize: screenWidth > 600 ? 18 : 16,
                fontWeight: FontWeight.w600,
                color: Colors.green,
                fontFamily: 'Quicksand',
              ),
            ),
            const SizedBox(height: 8),
            // Content
            SizedBox(
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.requests.scheduleIds.length,
                itemBuilder: (context, index) {
                  final schedule = requestDetailList?[index];

                  if (schedule == null) {
                    return Container();
                  }

                  final scheduleDate = DateTime.parse(schedule.workingDate);
                  // final isDateValid = scheduleDate.isBefore(currentDate) ||
                  //     scheduleDate.isAtSameMomentAs(currentDate);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(
                            DateFormat('dd-MM-yyyy')
                                .format(DateTime.parse(schedule.workingDate)),
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              color: Colors.grey,
                              fontSize: screenWidth > 600 ? 16 : 14,
                            ),
                          ),
                        ),
                        if (requestDetailList![index].status == 'waitPayment')
                          Flexible(
                            flex: 1,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  // _doneRequest(requestDetailList![index]);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => PaymentPage(
                                  //       amount:
                                  //           requestDetailList![index].cost ??
                                  //               500000,
                                  //       customer: widget.customer,
                                  //       costFactors: widget.costFactors,
                                  //       services: widget.services,
                                  //       requestDetail:
                                  //           requestDetailList![index],
                                  //       token: widget.token,
                                  //       refreshToken: widget.refreshToken,
                                  //     ),
                                  //   ),
                                  // );
                                });
                              },
                              child: Text(
                                'Xác nhận và thanh toán',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontSize: screenWidth > 600 ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                  decorationThickness: 2.0,
                                  decorationColor: Colors.red,
                                ),
                              ),
                            ),
                          )
                        else
                          Flexible(
                            flex: 1,
                            child: Text(
                              requestDetailList?[index].status == 'done'
                                  ? 'Đã thanh toán'
                                  : 'Chưa tiến hành',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: screenWidth > 600 ? 16 : 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    requestDetailList![index].status == 'done'
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // OK button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  print(isAllFinish);
                  for (var requesDetail in requestDetailList!) {
                    print("tình trạng ${requesDetail.status}");
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  isAllFinish ? 'Tiến hành thanh toán' : 'OK',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function to show the dialog
void showConfirmLongTermDayDialog(BuildContext context, Requests requests,
    Customer customer, List<CostFactor> costFactors, List<Services> services, String token, String refreshToken) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmLongTermDay(
        requests: requests,
        customer: customer,
        costFactors: costFactors,
        services: services,
        token: token,
        refreshToken: refreshToken,
      );
    },
  );
}
