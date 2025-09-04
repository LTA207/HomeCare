import 'dart:async';
import 'package:flutter/material.dart';

import '../data/model/request.dart';
import '../data/repository/repository.dart';

class RequestProvider extends ChangeNotifier {
  List<Requests> _requests = [];
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<Requests> get requests => _requests;
  bool get isLoading => _isLoading;

  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();

    var repository = DefaultRepository();
    var data = await repository.loadRequest('');

    if (!disposed) { // Kiểm tra nếu provider còn tồn tại
      _requests = data ?? [];
      _isLoading = false;
      notifyListeners();
    }
  }

  void autoRefresh() {
    _pollingTimer?.cancel(); // Hủy timer cũ nếu có
    _pollingTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      await fetchRequests();
    });
  }
  bool disposed = false;

  @override
  void dispose() {
    disposed = true; // Đánh dấu là provider đã bị hủy
    _pollingTimer?.cancel();
    super.dispose();
  }
}
