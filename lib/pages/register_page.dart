import 'package:flutter/material.dart';
import 'package:foodapp/auth/login_or_register.dart';
import 'package:foodapp/components/my_button.dart';
import 'package:foodapp/components/my_textfield.dart';
import 'package:foodapp/components/warning_dialog.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/pages/authen_page.dart';
import 'package:foodapp/pages/login_page.dart';
import 'package:lottie/lottie.dart';

import '../components/city_selected.dart';
import '../components/spashscreen.dart';
import '../data/model/location.dart';
import '../data/repository/repository.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<Location> locations = [];
  List<Customer> customers = [];

  String? phoneError;
  String? passwordError;
  String? confirmError;
  String? fullNameError;
  String? addressError;
  String? emailError;
  bool isLoading = false;
  bool isLocationLoading = true;

  Location? selectedProvince;
  String? selectedWard;
  String? selectedDetailedAddress;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var repository = DefaultRepository();
    var dataLocation = await repository.loadLocation();
    var dataCustomer = await repository.loadCustomer('');
    if (mounted) {
      setState(() {
        locations = dataLocation ?? [];
        customers = dataCustomer ?? [];
        isLocationLoading = false;
      });
    }
  }

  Future<void> validateAndRegister() async {
    setState(() {
      phoneError = null;
      passwordError = null;
      confirmError = null;
      fullNameError = null;
      addressError = null;
      emailError = null;
      isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmController.text.trim();
    String fullName = fullNameController.text.trim();
    String email = emailController.text.trim();

    bool hasError = false;

    if (phone.isEmpty) {
      setState(() => phoneError = "Số điện thoại không được để trống.");
      hasError = true;
    } else if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      setState(() => phoneError = "Số điện thoại không hợp lệ.");
      hasError = true;
    }

    if (password.isEmpty) {
      setState(() => passwordError = "Mật khẩu không được để trống.");
      hasError = true;
    } else if (password.length < 6) {
      setState(() => passwordError = "Mật khẩu phải có ít nhất 6 ký tự.");
      hasError = true;
    }

    if (confirmPassword.isEmpty) {
      setState(() => confirmError = "Vui lòng xác nhận mật khẩu.");
      hasError = true;
    } else if (password != confirmPassword) {
      setState(() => confirmError = "Mật khẩu xác nhận không khớp.");
      hasError = true;
    }

    if (fullName.isEmpty) {
      setState(() => fullNameError = "Tên không được để trống");
      hasError = true;
    }

    if (email.isEmpty) {
      setState(() => emailError = "Email không được để trống");
      hasError = true;
    }

    if (selectedProvince == null ||
        selectedWard == null ||
        selectedDetailedAddress == null ||
        selectedDetailedAddress!.trim().isEmpty) {
      setState(() => addressError = "Vui lòng chọn đầy đủ địa chỉ.");
      hasError = true;
    }

    // if (customers.any((customer) => customer.phone == phone)) {
    //   showPopUpWarning(context, 'Số điện thoại này đã được đăng ký. Vui lòng chọn số khác');
    //   return;
    // }
    //
    // if (customers.any((customer) => customer.email == email)) {
    //   showPopUpWarning(context, 'Địa chỉ email này đã được đăng ký. Vui lòng chọn số khác');
    //   return;
    // }

    if (!hasError && mounted) {
      var customer = Customer(
        addresses: [
          Addresses(
              province: selectedProvince!.name,
              ward: selectedWard!,
              detailedAddress: selectedDetailedAddress!)
        ],
        points: [Points(point: 100000000, id: '')],
        phone: phone,
        name: fullName,
        password: password,
        email: email,
      );
      var repository = DefaultRepository();
      var res = await repository.remoteDataSource.registerCustomer(phone, password, fullName, email, customer.addresses.first);
      if(res!.message.contains('Đăng ký thành công')) {
        showPopUpWarning(context, 'Đăng ký thành công. Vui lòng đăng nhập để tiếp tục');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SplashScreen(deviceToken: '',),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        showPopUpWarning(context, res.message);
        return;
      }
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => AuthenticationPage(
      //       onTap: () {},
      //       customer: customer,
      //     ),
      //   ),
      // );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLocationLoading
          ? Center(
              child: Lottie.asset(
                'lib/images/loading.json',
                width: 100,
                height: 100,
                repeat: true,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Image.asset('lib/images/logo.png', width: 180, height: 180),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: fullNameController,
                    hintText: "Nhập tên của bạn",
                    errorText: fullNameError,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: phoneController,
                    hintText: "Nhập số điện thoại",
                    keyboardType: TextInputType.number,
                    errorText: phoneError,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: emailController,
                    hintText: "Nhập email",
                    keyboardType: TextInputType.emailAddress,
                    errorText: emailError,
                  ),
                  const SizedBox(height: 15),
                  SelectLocation(
                    locations: locations,
                    onProvinceSelected: (province) {
                      setState(() {
                        selectedProvince = province;
                        addressError = null;
                      });
                    },
                    onWardSelected: (ward) {
                      setState(() {
                        selectedWard = ward;
                        addressError = null;
                      });
                    },
                    onAddressChanged: (detailedAddress) {
                      setState(() {
                        selectedDetailedAddress = detailedAddress;
                        addressError = null;
                      });
                    },
                  ),
                  if (addressError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Căn giữa hàng ngang
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 16),
                          const SizedBox(
                              width: 5), // Khoảng cách giữa icon và text
                          Text(
                            addressError!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: passwordController,
                    hintText: "Nhập mật khẩu",
                    obscureText: true,
                    errorText: passwordError,
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: confirmController,
                    hintText: "Xác nhận mật khẩu",
                    obscureText: true,
                    errorText: confirmError,
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    text: isLoading ? "Đang đăng ký..." : "Đăng ký",
                    onTap: isLoading ? null : validateAndRegister,
                  ),
                ],
              ),
            ),
    );
  }
}
