import 'package:flutter/material.dart';
import 'package:foodapp/data/model/helper.dart';

import '../data/repository/repository.dart';

class RatingHelperPage extends StatefulWidget {
  final Helper helper;
  final String detailId;
  final String token;
  final String refreshToken;

  const RatingHelperPage({
    super.key,
    required this.helper, required this.detailId, required this.token, required this.refreshToken,
  });

  @override
  State<RatingHelperPage> createState() => _RatingHelperPageState();
}

class _RatingHelperPageState extends State<RatingHelperPage> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  // Report issues list
  final List<Map<String, dynamic>> _reportIssues = [
    {'name': 'Đi trễ', 'isSelected': false},
    {'name': 'Không đến', 'isSelected': false},
    {'name': 'Khác', 'isSelected': false},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() async {
    bool hasSelectedIssue = _reportIssues.any((issue) => issue['isSelected']);

    if (!hasSelectedIssue && _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn vấn đề hoặc mô tả chi tiết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get the selected issue (only one since we're using radio buttons)
      String? selectedIssue = _reportIssues
          .firstWhere((issue) => issue['isSelected'], orElse: () => {'name': null})['name'];

      // Prepare report data
      String description = _descriptionController.text.trim();

      // Call API to submit report with single issue
      var repository = DefaultRepository();
      bool isSuccess = await repository.submitHelperReport(widget.detailId, selectedIssue ?? '', description, widget.token);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Báo cáo thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Quicksand',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Báo cáo của bạn đã được gửi thành công.\nChúng tôi sẽ xem xét và xử lý trong thời gian sớm nhất.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Quicksand',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(true); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Báo cáo Helper',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelperCard(),
            const SizedBox(height: 24),
            _buildReportIssues(),
            const SizedBox(height: 24),
            _buildDescriptionSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHelperCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            backgroundImage: widget.helper.avatar?.isNotEmpty == true
                ? NetworkImage(widget.helper.avatar!)
                : null,
            child: widget.helper.avatar?.isNotEmpty != true
                ? Icon(Icons.person, size: 30, color: Colors.grey[400])
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.helper.fullName ?? 'No Name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Quicksand',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.helper.helperId ?? 'No ID',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontFamily: 'Quicksand',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportIssues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vấn đề gặp phải',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chọn một vấn đề bạn gặp phải với người giúp việc này:',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Quicksand',
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: _reportIssues.map((issue) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<String>(
                      value: issue['name'],
                      groupValue: _reportIssues.firstWhere(
                        (item) => item['isSelected'],
                        orElse: () => {'name': null}
                      )['name'],
                      onChanged: (String? value) {
                        setState(() {
                          // Reset all selections
                          for (var item in _reportIssues) {
                            item['isSelected'] = false;
                          }
                          // Set the selected one
                          issue['isSelected'] = true;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        issue['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mô tả chi tiết',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Quicksand',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Mô tả chi tiết về vấn đề bạn gặp phải...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'Quicksand',
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.red.shade300, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Báo cáo của bạn sẽ được xem xét và xử lý trong thời gian sớm nhất. Vui lòng cung cấp thông tin chính xác.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'Quicksand',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Gửi báo cáo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Quicksand',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
