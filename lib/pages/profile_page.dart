import 'package:flutter/material.dart';
import 'package:foodapp/components/my_textfield.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/pages/F.A.QPage.dart';
import 'package:foodapp/pages/center_support_page.dart';
import 'package:foodapp/pages/choose_location_page.dart';
import 'package:foodapp/pages/customer_right_page.dart';
import 'package:foodapp/pages/edit_information_page.dart';
import 'package:foodapp/pages/feedback_complaint_page.dart';
import 'package:foodapp/pages/login_page.dart';
import 'package:foodapp/pages/policy.dart';
import 'package:foodapp/pages/register_page.dart';
import 'package:foodapp/pages/training_helper_page.dart';

class ProfilePage extends StatefulWidget {
  final Customer customer;
  final String token;
  final String refreshToken;
  final String deviceToken;

  ProfilePage(
      {required this.customer,
      required this.token,
      required this.refreshToken,
      required this.deviceToken});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int index = 0;

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Xác nhận",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Bạn có chắc chắn muốn xóa tài khoản không?",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Không",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPasswordDialog(context);
              },
              child: Text(
                "Dạ Cóa",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Xác nhận",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Bạn có chắc chắn muốn đăng xuất không?",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Không",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(
                                deviceToken: widget.deviceToken,
                              )),
                    );
                  },
                  child: Text(
                    "Dạ Cóa",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Nhập mật khẩu",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyTextField(
              controller: passwordController,
              hintText: 'Nhập mật khẩu',
              obscureText: true,
              keyboardType: TextInputType.text,
            )
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Container(
            width: 100, // Định kích thước nút
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Hủy",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            width: 130, // Định kích thước nút
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSuccessDialog(context);
              },
              child: Text(
                "Xác nhận xoá",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Thành công",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "Tài khoản đã được xóa thành công.",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(
                            deviceToken: widget.deviceToken,
                          )),
                );
              },
              child: Text(
                "OK",
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar
          SliverAppBar(
            expandedHeight: 200,
            automaticallyImplyLeading: false,
            floating: false,
            pinned: true,
            actions: [
              // In the ProfilePage class, modify the GestureDetector inside the SliverAppBar actions:

              GestureDetector(
                onTap: () async {
                  final updatedCustomer = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditInformationPage(
                        customer: widget.customer,
                      ),
                    ),
                  );

                  if (updatedCustomer != null) {
                    setState(() {
                      // Update the customer information if changes were made
                      widget.customer.name = updatedCustomer.name;
                      widget.customer.phone = updatedCustomer.phone;
                      // The addresses would have been updated by reference already
                    });
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Chỉnh sửa',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green.shade600, Colors.green.shade800],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    _buildLocationSection(),
                  ],
                ),
              ),
            ),
          ),
          // SliverList
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // Section Cá nhân
                _buildSection(
                  context,
                  "Cá nhân",
                  [
                    MenuItem(Icons.edit_calendar, "Lịch sử thanh toán", () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => const PaymentHistorySheet()),
                      // );
                    }),
                    MenuItem(Icons.person_off_rounded, "Yêu cầu xóa tài khoản",
                        () {
                      _showConfirmationDialog(context);
                    }),
                  ],
                ),
                // Section Quy trình, điều khoản, chính sách
                _buildSection(
                  context,
                  "Quy trình, điều khoản, chính sách",
                  [
                    MenuItem(
                        Icons.person_pin_rounded, "Quyền lợi của khách hàng",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomerRight()),
                      );
                    }),
                    MenuItem(Icons.gavel_rounded, "Pháp lý", () {
                      // _showStaticDialog(
                      //     context, "Pháp lý đang được thử nghiệm.");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PolicyScreen()),
                      );
                    }),
                    MenuItem(Icons.school, "Quy trình đào tạo người giúp việc",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TrainingHelperPage()),
                      );
                    }),
                  ],
                ),
                // Section Trợ giúp & hỗ trợ
                _buildSection(
                  context,
                  "Trợ giúp & hỗ trợ",
                  [
                    MenuItem(Icons.headset_mic, "Trung tâm hỗ trợ", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SupportCenterPage()),
                      );
                    }),
                    MenuItem(Icons.question_mark_rounded, "Câu hỏi thường gặp",
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FAQScreen()),
                      );
                    }),
                    MenuItem(Icons.question_answer_rounded,
                        "Góp ý, khiếu nại qua App", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FeedbackComplaintsPage()),
                      );
                    }),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      _showConfirmationLogoutDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Đăng xuất",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Phiên bản
                const Center(
                  child: Text(
                    "Version 11.3.5",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng section với tiêu đề và danh sách các menu item
  Widget _buildSection(
      BuildContext context, String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                items.map((item) => _buildMenuItem(context, item)).toList(),
          ),
        ),
      ],
    );
  }

  // Xây dựng từng item trong danh sách menu
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: ListTile(
        leading: Icon(item.icon, color: Colors.green.shade600, size: 22),
        title: Text(
          item.title,
          style: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: item.onTap,
      ),
    );
  }

  Widget _buildLocationSection() {
    return GestureDetector(
      onTap: () async {
        final selectedIndex = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChooseLocationPage(
              customer: widget.customer,
              token: widget.token,
              refreshToken: widget.refreshToken,
            ),
          ),
        );
        if (selectedIndex != null) {
          setState(() => index = selectedIndex);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                widget.customer.addresses[index].toString(),
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_right_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại tĩnh
  void _showStaticDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => Container(
        child: AlertDialog(
          title: const Text(
            "Thông báo",
            style: TextStyle(fontFamily: 'Quicksand'),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("OK", style: TextStyle(fontFamily: 'Quicksand')),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  MenuItem(this.icon, this.title, this.onTap);
}
