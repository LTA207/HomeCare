import 'package:flutter/material.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/data/model/location.dart';
import '../data/repository/repository.dart';

class AuthProvider extends ChangeNotifier {
  final DefaultRepository _repository = DefaultRepository();

  // Auth state
  bool _isLoading = false;
  bool _isLoginSuccess = false;
  Customer? _customer;
  String _token = '';
  String _refreshToken = '';
  List<Requests> _requestsCustomer = [];
  List<Services> _services = [];
  List<Location> _locations = [];
  List<Customer> _customers = [];

  // Error states
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;
  String? _fullNameError;
  String? _addressError;
  String? _emailError;
  String? _generalError;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoginSuccess => _isLoginSuccess;
  Customer? get customer => _customer;
  String get token => _token;
  String get refreshToken => _refreshToken;
  List<Requests> get requestsCustomer => _requestsCustomer;
  List<Services> get services => _services;
  List<Location> get locations => _locations;
  List<Customer> get customers => _customers;

  String? get phoneError => _phoneError;
  String? get passwordError => _passwordError;
  String? get confirmError => _confirmError;
  String? get fullNameError => _fullNameError;
  String? get addressError => _addressError;
  String? get emailError => _emailError;
  String? get generalError => _generalError;

  // Clear errors
  void clearErrors() {
    _phoneError = null;
    _passwordError = null;
    _confirmError = null;
    _fullNameError = null;
    _addressError = null;
    _emailError = null;
    _generalError = null;
    notifyListeners();
  }

  void clearFieldError(String field) {
    switch (field) {
      case 'phone':
        _phoneError = null;
        break;
      case 'password':
        _passwordError = null;
        break;
      case 'confirm':
        _confirmError = null;
        break;
      case 'fullName':
        _fullNameError = null;
        break;
      case 'address':
        _addressError = null;
        break;
      case 'email':
        _emailError = null;
        break;
    }
    notifyListeners();
  }

  // Load initial data
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final servicesData = await _repository.loadServices();

      _services = servicesData ?? [];
    } catch (e) {
      _generalError = 'Không thể tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load registration data
  Future<void> loadRegistrationData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final locationData = await _repository.loadLocation();
      final customerData = await _repository.loadCustomer('');

      _locations = locationData ?? [];
      _customers = customerData ?? [];
    } catch (e) {
      _generalError = 'Không thể tải dữ liệu đăng ký: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Validation methods
  String? validatePhone(String value) {
    if (value.isEmpty) {
      return "Số điện thoại không được để trống";
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return "Số điện thoại không hợp lệ. Vui lòng nhập 10 số";
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return "Mật khẩu không được để trống";
    }
    if (value.length < 6) {
      return "Mật khẩu phải có ít nhất 6 ký tự";
    }
    return null;
  }

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return "Email không được để trống";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return "Email không hợp lệ";
    }
    return null;
  }

  String? validateFullName(String value) {
    if (value.isEmpty) {
      return "Tên không được để trống";
    }
    return null;
  }

  String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return "Vui lòng xác nhận mật khẩu";
    }
    if (password != confirmPassword) {
      return "Mật khẩu xác nhận không khớp";
    }
    return null;
  }

  // Login method
  Future<bool> login(String phone, String password, String deviceToken) async {
    clearErrors();

    // Validate inputs
    _phoneError = validatePhone(phone);
    _passwordError = validatePassword(password);

    if (_phoneError != null || _passwordError != null) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _isLoginSuccess = false;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final authData = await _repository.loginCustomer(phone, password);

      if (authData != null) {
        _token = authData.accessToken;
        _refreshToken = authData.refreshToken;

        // Register device token
        await _repository.registerDeviceToken(authData.user.phone, deviceToken);

        // Load customer data
        final customerData = await _repository.loadCustomerInfo(authData.user.phone, _token);
        final requestData = await _repository.loadCustomerRequest(authData.user.phone, _token);

        _customer = customerData;
        _requestsCustomer = requestData ?? [];
        _isLoginSuccess = true;

        notifyListeners();
        return true;
      } else {
        _passwordError = "Số điện thoại hoặc mật khẩu không đúng";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _generalError = "Đăng nhập thất bại: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register method
  Future<bool> register({
    required String phone,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String email,
    required Location? selectedProvince,
    required String? selectedWard,
    required String? selectedDetailedAddress,
  }) async {
    clearErrors();

    // Validate inputs
    _phoneError = validatePhone(phone);
    _passwordError = validatePassword(password);
    _confirmError = validateConfirmPassword(password, confirmPassword);
    _fullNameError = validateFullName(fullName);
    _emailError = validateEmail(email);

    if (selectedProvince == null ||
        selectedWard == null ||
        selectedDetailedAddress == null ||
        selectedDetailedAddress.trim().isEmpty) {
      _addressError = "Vui lòng chọn đầy đủ địa chỉ";
    }

    if (_phoneError != null ||
        _passwordError != null ||
        _confirmError != null ||
        _fullNameError != null ||
        _emailError != null ||
        _addressError != null) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final customer = Customer(
        addresses: [
          Addresses(
            province: selectedProvince!.name,
            ward: selectedWard!,
            detailedAddress: selectedDetailedAddress!,
          )
        ],
        points: [Points(point: 100000000, id: '')],
        phone: phone,
        name: fullName,
        password: password,
        email: email,
      );

      final result = await _repository.remoteDataSource.registerCustomer(
        phone,
        password,
        fullName,
        email,
        customer.addresses.first
      );

      if (result != null && result.message.contains('Đăng ký thành công')) {
        return true;
      } else {
        _generalError = result?.message ?? 'Đăng ký thất bại';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _generalError = "Đăng ký thất bại: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout method
  void logout() {
    _customer = null;
    _token = '';
    _refreshToken = '';
    _requestsCustomer = [];
    _isLoginSuccess = false;
    clearErrors();
    notifyListeners();
  }

  // Reset login success state
  void resetLoginSuccess() {
    _isLoginSuccess = false;
    notifyListeners();
  }
}
