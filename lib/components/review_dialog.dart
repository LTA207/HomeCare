import 'package:flutter/material.dart';
import 'package:foodapp/data/repository/repository.dart';

class ReviewDialog extends StatefulWidget {
  final String? requestId;
  final String token;
  final VoidCallback? onReviewSubmitted;
  final VoidCallback? onSkipped;

  const ReviewDialog({
    Key? key,
    this.requestId,
    required this.token,
    this.onReviewSubmitted,
    this.onSkipped,
  }) : super(key: key);

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();

  static Future<void> show({
    required BuildContext context,
    String? requestId,
    required String token,
    VoidCallback? onReviewSubmitted,
    VoidCallback? onSkipped,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReviewDialog(
          requestId: requestId,
          token: token,
          onReviewSubmitted: onReviewSubmitted,
          onSkipped: onSkipped,
        );
      },
    );
  }
}

class _ReviewDialogState extends State<ReviewDialog> {
  final TextEditingController _reviewController = TextEditingController();
  bool _loseThings = false;
  bool _breakThings = false;
  int _rating = 5;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Rất không hài lòng';
      case 2:
        return 'Không hài lòng';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Hài lòng';
      case 5:
        return 'Rất hài lòng';
      default:
        return 'Chưa đánh giá';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _submitReview() async {
    String review = _reviewController.text.trim();

    print('Review submitted:');
    print('Rating: $_rating stars');
    print('Review: $review');
    print('Break things: $_breakThings');
    print('Lose things: $_loseThings');

    if (widget.requestId != null) {
      try {
        var repository = DefaultRepository();
        await repository.postReview(
          widget.requestId!,
          review,
          _loseThings,
          _breakThings,
          _rating,
          widget.token,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cảm ơn bạn đã đánh giá $_rating sao!',
              style: TextStyle(fontFamily: 'Quicksand'),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        widget.onReviewSubmitted?.call();
      } catch (e) {
        print('Error submitting review: $e');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Có lỗi xảy ra khi gửi đánh giá. Vui lòng thử lại!',
              style: TextStyle(fontFamily: 'Quicksand'),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('No request ID available for review');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Không thể gửi đánh giá do thiếu thông tin đơn hàng.',
            style: TextStyle(fontFamily: 'Quicksand'),
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(Icons.rate_review, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            'Đánh giá dịch vụ',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đánh giá chất lượng dịch vụ:',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.star,
                      size: 35,
                      color: index < _rating
                          ? Colors.amber
                          : Colors.grey[300],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                _getRatingText(_rating),
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getRatingColor(_rating),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Hãy chia sẻ trải nghiệm của bạn về dịch vụ:',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập đánh giá của bạn...',
                hintStyle: TextStyle(
                  fontFamily: 'Quicksand',
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                contentPadding: EdgeInsets.all(12),
              ),
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Báo cáo sự cố (nếu có):',
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text(
                'Vỡ đồ vật',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                ),
              ),
              value: _breakThings,
              onChanged: (bool? value) {
                setState(() {
                  _breakThings = value ?? false;
                });
              },
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: Text(
                'Làm mất đồ',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 14,
                ),
              ),
              value: _loseThings,
              onChanged: (bool? value) {
                setState(() {
                  _loseThings = value ?? false;
                });
              },
              activeColor: Colors.red,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSkipped?.call();
          },
          child: Text(
            'Bỏ qua',
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _submitReview();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: Text(
            'Gửi đánh giá',
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

