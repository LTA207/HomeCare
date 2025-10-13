import 'package:foodapp/data/model/request.dart';

class RequestDetail {
  Comment comment;
  String id;
  String workingDate;
  String helperID;
  String status;
  num? cost;
  num helperCost;
  DateTime startTime;
  DateTime endTime;
  num? totalCost;
  String? serviceTitle;

  RequestDetail(
      {required this.id,
      required this.workingDate,
      required this.helperID,
      required this.status,
      required this.cost,
      required this.helperCost,
      required this.comment,
      required this.startTime,
      required this.endTime,
      required this.totalCost,
      this.serviceTitle});

  factory RequestDetail.fromJson(Map<String, dynamic> map) {
    return RequestDetail(
        id: map['_id'] ?? '',
        helperCost: map['helper_cost'] ?? 0,
        helperID: map['helper_id'] ?? '',
        status: map['status'] ?? '',
        workingDate: map['workingDate'] ?? '',
        // Parsing to DateTime with null safety
        comment: map['comment'] != null
            ? Comment.fromJson(map['comment'])
            : Comment(review: '', loseThings: false, breakThings: false),
        cost: map['cost'] ?? 0,
        startTime: map['startTime'] != null
            ? DateTime.parse(map['startTime'])
            : DateTime.now(),
        // Parsing to DateTime with null safety
        endTime: map['endTime'] != null
            ? DateTime.parse(map['endTime'])
            : DateTime.now(),
        // Parsing to DateTime with null safety
        totalCost: map['totalCost'] ?? 0,
        serviceTitle: map['service'] ?? ''
    );
  }

  @override
  String toString() {
    return 'RequestDetail{comment: $comment, id: $id, workingDate: $workingDate, helperID: $helperID, status: $status, helperCost: $helperCost, startTime: $startTime, endTime: $endTime, totalCost: $totalCost}';
  }
}
