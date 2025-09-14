import 'package:flutter/material.dart';
import '../components/city_selected.dart';
import '../data/model/customer.dart';
import '../data/model/location.dart';
import '../data/repository/repository.dart';

class EditLocationPage extends StatefulWidget {
  final Customer customer;
  final Location? initialProvince;
  final String? initialWard;
  final String? initialDetailedAddress;
  final Function(Location)? onProvinceSelected;
  final Function(String)? onWardSelected;
  final Function(String)? onDetailedAddressChanged;
  final Function onAddressUpdated;

  EditLocationPage({
    super.key,
    required this.customer,
    this.initialProvince,
    this.initialWard,
    this.initialDetailedAddress,
    this.onProvinceSelected,
    this.onWardSelected,
    this.onDetailedAddressChanged,
    required this.onAddressUpdated,
  });

  @override
  State<EditLocationPage> createState() => _EditLocationPageState();
}

class _EditLocationPageState extends State<EditLocationPage> {
  late List<Location> locations = [];
  Location? selectedProvince;
  String? selectedWard;
  String? detailedAddress;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedProvince = widget.initialProvince;
    selectedWard = widget.initialWard;
    detailedAddress = widget.initialDetailedAddress;
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    var repository = DefaultRepository();
    var data = await repository.loadLocation();
    setState(() {
      locations = data ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectLocation(
            locations: locations,
            onProvinceSelected: (Location province) {
              setState(() {
                selectedProvince = province;
              });
              widget.onProvinceSelected?.call(province);
            },
            onWardSelected: (String ward) {
              setState(() {
                selectedWard = ward;
              });
              widget.onWardSelected?.call(ward);
            },
            onAddressChanged: (String address) {
              setState(() {
                detailedAddress = address;
              });
              widget.onDetailedAddressChanged?.call(address);
            },
          ),
          const Divider(height: 16, color: Colors.grey),
          ElevatedButton(
            onPressed: () {
              if (selectedProvince != null &&
                  selectedWard != null &&
                  detailedAddress != null &&
                  detailedAddress!.isNotEmpty) {
                Navigator.pop(context, {
                  'province': selectedProvince,
                  'ward': selectedWard,
                  'detailedAddress': detailedAddress,
                });
              }
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child:
            const Text("Lưu", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
