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
      required this.totalCost});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestDetail &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          workingDate == other.workingDate &&
          helperID == other.helperID &&
          status == other.status &&
          cost == other.cost &&
          helperCost == other.helperCost &&
          totalCost == other.totalCost;

  @override
  int get hashCode =>
      id.hashCode ^
      workingDate.hashCode ^
      helperID.hashCode ^
      status.hashCode ^
      helperCost.hashCode ^
      totalCost.hashCode;

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
        totalCost: map['totalCost'] ?? 0);
  }

  @override
  String toString() {
    return 'RequestDetail{comment: $comment, id: $id, workingDate: $workingDate, helperID: $helperID, status: $status, helperCost: $helperCost, startTime: $startTime, endTime: $endTime, totalCost: $totalCost}';
  }
}
