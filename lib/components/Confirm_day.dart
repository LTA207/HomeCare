import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final List<Services> services;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const ConfirmLongTermDay(
      {super.key,
      required this.requests,
      required this.customer,
      required this.services,
      required this.token,
      required this.refreshToken,
      required this.deviceToken});

  @override
  State<ConfirmLongTermDay> createState() => _ConfirmLongTermDayState();
}

class _ConfirmLongTermDayState extends State<ConfirmLongTermDay> {
  List<RequestDetail>? requestDetailList;

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
                        Flexible(
                          flex: 1,
                          child: Text(
                            requestDetailList?[index].status == 'completed'
                                ? 'Đã hoàn thành'
                                : requestDetailList?[index].status == 'waitPayment'
                                    ? 'Chờ thanh toán'
                                    : 'Chưa tiến hành',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: screenWidth > 600 ? 16 : 14,
                              fontWeight: FontWeight.w600,
                              color: requestDetailList![index].status == 'completed'
                                  ? Colors.green
                                  : requestDetailList![index].status == 'waitPayment'
                                      ? Colors.orange
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
            // Payment button
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
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        amount: widget.requests.totalCost,
                        customer: widget.customer,
                        services: widget.services,
                        requestDetail: widget.requests.schedules.first,
                        request: widget.requests,
                        token: widget.token,
                        refreshToken: widget.refreshToken,
                        deviceToken: widget.deviceToken,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Tiến hành thanh toán',
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
    Customer customer, List<Services> services, String token, String refreshToken, String deviceToken) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmLongTermDay(
        requests: requests,
        customer: customer,
        services: services,
        token: token,
        refreshToken: refreshToken,
        deviceToken: deviceToken,
      );
    },
  );
}
