import 'package:flutter/material.dart';
import 'package:foodapp/pages/edit_location_page.dart';
import 'package:foodapp/pages/home_page.dart';
import '../data/model/customer.dart';
import '../data/model/location.dart';
import '../data/source/source.dart';

class ChooseLocationPage extends StatefulWidget {
  final Customer customer;
  final Location? selectedProvince;
  final String? selectedWard;
  final String? detailedAddress;
  final String token;
  final String refreshToken;

  const ChooseLocationPage(
      {super.key,
      required this.customer,
      this.selectedProvince,
      this.selectedWard,
      this.detailedAddress, required this.token, required this.refreshToken});

  @override
  _ChooseLocationPageState createState() => _ChooseLocationPageState();
}

class _ChooseLocationPageState extends State<ChooseLocationPage> {
  Location? selectedProvince;
  String? selectedWard;
  String? detailedAddressChanged;

  void addAddress() {
    setState(() {
      widget.customer.addresses.add(Addresses(
          province: selectedProvince!.name,
          ward: selectedWard!,
          detailedAddress: detailedAddressChanged!));
    });
  }

  void modifyAddress(int index) {
    setState(() {
      widget.customer.addresses[index] = Addresses(
        province: selectedProvince!.name,
        ward: selectedWard!,
        detailedAddress: detailedAddressChanged!,
      );
    });
  }

  void addAddressFromResult(Map result) async {
    setState(() {
      widget.customer.addresses.add(Addresses(
        province: result['province'].name,
        ward: result['ward'],
        detailedAddress: result['detailedAddress'],
      ));
    });
    await RemoteDataSource().updateCustomerInfo(widget.customer, widget.token);
  }

  void modifyAddressFromResult(int index, Map result) async {
    print(result);
    setState(() {
      widget.customer.addresses[index] = Addresses(
        province: result['province'].name,
        ward: result['ward'],
        detailedAddress: result['detailedAddress'],
      );
    });
    await RemoteDataSource().updateCustomerInfo(widget.customer, widget.token);
  }

  void setDefaultAddress(int index) async {
    setState(() {
      final address = widget.customer.addresses.removeAt(index);
      widget.customer.addresses.insert(0, address);
    });
    await RemoteDataSource().updateCustomerInfo(widget.customer, widget.token);
  }

  void _onAddressSelected(BuildContext context, int addressIndex) {
    setDefaultAddress(addressIndex);
    Navigator.pop(context, 0); // Địa chỉ mặc định luôn ở đầu danh sách
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        title: const Text(
          "Địa chỉ của bạn",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildAddAddressButton(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildAddressCard(index),
                childCount: widget.customer.addresses.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: Colors.green,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditLocationPage(
                  customer: widget.customer,
                  // Không truyền giá trị ban đầu khi thêm mới
                  onProvinceSelected: (Location province) {
                    setState(() => selectedProvince = province);
                  },
                  onWardSelected: (String ward) {
                    setState(() => selectedWard = ward);
                  },
                  onDetailedAddressChanged: (String detailedAddress) {
                    setState(() => detailedAddressChanged = detailedAddress);
                  },
                  onAddressUpdated: () {}, // Không dùng nữa
                ),
              ),
            );
            if (result != null) {
              addAddressFromResult(result);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_location_alt_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Thêm địa chỉ mới",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(int index) {
    print(widget.customer.addresses[index].toString());
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 0.5,
          color: Colors.green,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onAddressSelected(context, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.customer.name ?? 'Tên không có sẵn',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.customer.phone ?? 'Số điện thoại không có sẵn',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.customer.addresses[index].toString(),
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final address = widget.customer.addresses[index];
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditLocationPage(
                          customer: widget.customer,
                          initialProvince: null, // Nếu có thể lấy Location từ tên, hãy truyền vào
                          initialWard: address.ward,
                          initialDetailedAddress: address.detailedAddress,
                          onProvinceSelected: (Location province) {
                            setState(() => selectedProvince = province);
                          },
                          onWardSelected: (String ward) {
                            setState(() => selectedWard = ward);
                          },
                          onDetailedAddressChanged: (String detailedAddress) {
                            setState(
                                () => detailedAddressChanged = detailedAddress);
                          },
                          onAddressUpdated: () {}, // Không dùng nữa
                        ),
                      ),
                    );
                    if (result != null) {
                      modifyAddressFromResult(index, result);
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    "Sửa",
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
