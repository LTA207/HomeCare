import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:foodapp/pages/helper_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:foodapp/data/model/helper.dart';
import 'package:foodapp/data/model/customer.dart';
import 'package:foodapp/data/model/request.dart';
import 'package:foodapp/data/model/service.dart';
import 'package:foodapp/data/model/CostFactor.dart';
import 'package:foodapp/data/model/TimeOff.dart';
import 'package:foodapp/pages/review_order_page.dart';
import 'package:foodapp/data/repository/repository.dart';

class HelperList extends StatefulWidget {
  final Customer customer;
  final Requests request;
  final List<CostFactor> costFactors;
  final List<DateTime> listDate;
  final bool isOnDemand;
  final List<Services> services;
  final Services service;
  final String token;
  final String refreshToken;
  final String deviceToken;

  const HelperList({
    super.key,
    required this.customer,
    required this.request,
    required this.listDate,
    required this.isOnDemand,
    required this.costFactors,
    required this.services,
    required this.service, required this.token, required this.refreshToken, required this.deviceToken,
  });

  @override
  State<HelperList> createState() => _HelperListState();
}

class _HelperListState extends State<HelperList> {
  late List<Helper> helpers = [];
  late List<TimeOff> timeOffList = [];
  bool _isLoading = true;
  String _selectedFilter = 'Gần đây';
  final List<String> _filters = [
    'Gần đây',
    'Tất cả',
    'Kinh nghiệm',
    'Đánh giá',
    'Khoảng cách'
  ];

  @override
  void initState() {
    super.initState();
    loadHelperData();
    loadTimeOffData();
  }

  Future<void> loadHelperData() async {
    var repository = DefaultRepository();
    var data = await repository.loadCleanerData();
    if (data == null) {
      helpers = [];
    } else {
      helpers = data;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadTimeOffData() async {
    var repository = DefaultRepository();
    var data = await repository.loadTimeOff();
    timeOffList = data ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final filteredHelpers = _filterHelpers();

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Chọn người giúp việc',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Quicksand',
            ),
          ),
          backgroundColor: Colors.green,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          actions: [
            GestureDetector(
              onTap: () => {
                widget.request.helperId = 'notAvailable',
                widget.request.startDate = widget.listDate
                    .map((date) => DateFormat('yyyy-MM-dd').format(date))
                    .join(','),
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewOrderPage(
                      customer: widget.customer,
                      request: widget.request,
                      costFactors: widget.costFactors,
                      services: widget.services,
                      service: widget.service,
                      token: widget.token,
                      refreshToken: widget.refreshToken,
                      deviceToken: widget.deviceToken,
                    ),
                  ),
                ),
              },
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Bỏ qua',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Quicksand',
                        ),
                      )
                    ],
                  )),
            )
          ]),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const LoadingView()
          : filteredHelpers.isEmpty
              ? const EmptyStateView()
              : Column(
                  children: [
                    _buildFilterSection(),
                    Expanded(
                      child: _buildHelperGrid(filteredHelpers),
                    ),
                  ],
                ),
    );
  }

  List<Helper> _filterHelpers() {
    final availableHelpers = helpers.where((helper) {
      final isHelperInTimeOff =
          timeOffList.any((timeOff) => timeOff.helperId == helper.id);
      if (!isHelperInTimeOff) return true;

      final isDateOffWithinRange = timeOffList.any((timeOff) {
        if (timeOff.helperId != helper.id) return false;
        final timeOffDate = DateTime.parse(timeOff.dateOff);
        return widget.listDate
            .any((startDate) => isSameDay(timeOffDate, startDate));
      });
      return !isDateOffWithinRange;
    }).toList();

    switch (_selectedFilter) {
      case 'Tất cả':
        break;

      case 'Kinh nghiệm':
        availableHelpers
            .sort((a, b) => b.yearOfExperience.compareTo(a.yearOfExperience));
        break;
      case 'Đánh giá':
        // Implement rating sort when available
        break;
      case 'Khoảng cách':
        // Implement distance sort when available
        break;
    }

    return availableHelpers;
  }

  Widget _buildFilterSection() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.only(left: 20),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return FilterChip(
            label: Text(
              filter,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 15,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedFilter = filter);
            },
            selectedColor: isSelected ? Colors.green : Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.green,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'Quicksand',
            ),
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.green,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        },
      ),
    );
  }

  Widget _buildHelperGrid(List<Helper> helpers) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          children: List.generate(
            helpers.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 16), // Khoảng cách giữa các item
                child: HelperCard(
                  helper: helpers[index],
                  onTap: () => _navigateToReviewOrder(helpers[index]),
                  allServices: [],
                  services: widget.services,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToReviewOrder(Helper helper) {
    widget.request.helperId = helper.id;
    widget.request.startDate = widget.listDate
        .map((date) => DateFormat('yyyy-MM-dd').format(date))
        .join(',');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewOrderPage(
          customer: widget.customer,
          helper: null,
          request: widget.request,
          costFactors: widget.costFactors,
          services: widget.services,
          service: widget.service,
          token: widget.token,
          refreshToken: widget.refreshToken,
          deviceToken: widget.deviceToken,
        ),
      ),
    );
  }
}

class HelperCard extends StatelessWidget {
  final Helper helper;
  final VoidCallback onTap;
  final List<Service> allServices;
  final List<Services> services;

  const HelperCard({
    Key? key,
    required this.helper,
    required this.onTap,
    required this.allServices,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(), // Ảnh đại diện
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameAndRating(), // Tên và đánh giá
                      const SizedBox(height: 4),
                      _buildExperience(), // Kinh nghiệm
                      const SizedBox(height: 4),
                      _buildLocation(), // Khu vực làm việc
                      // const SizedBox(height: 6),
                      // _buildJobTags(), // Các công việc có thể làm
                      // const SizedBox(height: 6),
                      // _buildActionButton(), // Nút hành động
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildJobTags(),
              ],
            ),
            // Row(
            //   children: [
            //     _buildActionButton(context),
            //   ],
            // ),
            const SizedBox(height: 8),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  /// Ảnh đại diện
  Widget _buildAvatar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: helper.avatar != null && helper.avatar!.isNotEmpty
          ? Image.network(
              helper.avatar!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }

  /// Tên và đánh giá
  Widget _buildNameAndRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            helper.fullName ?? 'No Name',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text(
              '4.8', // Thay thế bằng dữ liệu đánh giá
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Kinh nghiệm
  Widget _buildExperience() {
    return Text(
      '${helper.yearOfExperience} năm kinh nghiệm',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[700],
        fontFamily: 'Quicksand',
      ),
    );
  }

  /// Khu vực làm việc
  Widget _buildLocation() {
    return Text(
      helper.workingArea.province,
      style: TextStyle(
        fontSize: 14,
        fontFamily: 'Quicksand',
        color: Colors.grey[700],
      ),
    );
  }

  /// Các công việc có thể làm
  Widget _buildJobTags() {
    List<Services> helperServices =
        services.where((service) => helper.jobs.contains(service.id)).toList();

    if (helperServices.isNotEmpty) {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: helperServices
                .map((service) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(service.title),
                        backgroundColor: Colors.green.shade50,
                        labelStyle: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          fontFamily: 'Quicksand',
                        ),
                        side: BorderSide(color: Colors.green.shade200),
                        padding: const EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ))
                .toList(),
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.shade200,
            )),
        child: Text(
          "Chưa tìm thấy kĩ năng của người giúp việc",
          style: TextStyle(
            fontSize: 12,
            color: Colors.green[800],
            fontFamily: 'Quicksand',
          ),
        ),
      );
    }
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Quicksand',
        ),
      ),
    );
  }

  /// Nút hành động (Chi tiết)
  Widget _buildActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HelperDetailPage(
                  helper: helper,
                  services: services,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text(
            'Thông tin',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text(
            'Chọn người này',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Quicksand',
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'lib/images/loading.json',
        width: 200,
        height: 200,
        repeat: true,
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No Helpers Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or try again later',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
