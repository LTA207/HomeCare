import 'package:flutter/material.dart';
import '../../data/model/location.dart';

class SelectLocation extends StatefulWidget {
  final List<Location> locations;
  final Function(Location)? onProvinceSelected;
  final Function(String)? onDistrictSelected;
  final Function(String)? onWardSelected;
  final Function(String) onAddressChanged;

  const SelectLocation({
    super.key,
    required this.locations,
    this.onProvinceSelected,
    this.onDistrictSelected,
    this.onWardSelected,
    required this.onAddressChanged,
  });

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  Location? selectedLocation;
  District? selectedDistrict;
  String? selectedWardName;
  String? detailedAddress;

  List<District> districts = [];
  List<Ward> wards = [];
  String address = '';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Tỉnh/Thành phố'),
            _buildLocationDropdown(),
            const SizedBox(height: 16),
            _buildSectionTitle('Quận/Huyện'),
            _buildDistrictDropdown(),
            const SizedBox(height: 16),
            _buildSectionTitle('Phường/Xã'),
            _buildWardDropdown(),
            const SizedBox(height: 16),
            _buildDetailedAddress(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Location>(
          value: selectedLocation,
          hint: _buildHintText("Chọn một tỉnh/thành"),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: (Location? newValue) {
            setState(() {
              selectedLocation = newValue;
              selectedDistrict = null;
              selectedWardName = null;
              wards = [];

              if (newValue != null) {
                districts = newValue.districts;
                widget.onProvinceSelected?.call(newValue);
              }
            });
          },
          items: widget.locations.map((Location location) {
            return DropdownMenuItem<Location>(
              value: location,
              child: Text(
                location.name,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<District>(
          value: selectedDistrict,
          hint: _buildHintText("Chọn một quận/huyện"),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: districts.isEmpty
              ? null
              : (District? newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                    selectedWardName = null;
                    wards = newValue?.wards ?? [];

                    if (newValue != null) {
                      widget.onDistrictSelected?.call(newValue.name);
                    }
                  });
                },
          items: districts.map((District district) {
            return DropdownMenuItem<District>(
              value: district,
              child: Text(
                district.name,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWardDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedWardName,
          hint: _buildHintText("Chọn một phường/xã"),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: wards.isEmpty
              ? null
              : (String? newValue) {
                  setState(() {
                    selectedWardName = newValue;
                    if (newValue != null) {
                      widget.onWardSelected?.call(newValue);
                    }
                  });
                },
          items: wards.map((Ward ward) {
            return DropdownMenuItem<String>(
              value: ward.name,
              child: Text(
                ward.name,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDetailedAddress() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onChanged: (value) {
          setState(() {
            detailedAddress = value;
          });
          widget.onAddressChanged(value);
        },
        decoration: InputDecoration(
          hintText: 'Nhập địa chỉ',
          hintStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontStyle: FontStyle.italic,
            fontSize: 15,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildHintText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Quicksand',
        fontStyle: FontStyle.italic,
        color: Colors.grey.shade500,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
