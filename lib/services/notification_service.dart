import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Định nghĩa màu chủ đạo của ứng dụng
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color white = Colors.white;
  static const Color darkGreen = Color(0xFF2E7D32);

  static Future<void> init() async {
    // Khởi tạo đơn giản - overlay_support không cần init phức tạp
    print('📱 NotificationService initialized');
  }

  // Hiển thị thông báo in-app với overlay
  static void showInAppNotification({
    required String title,
    required String body,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    showOverlayNotification(
      (context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              OverlaySupportEntry.of(context)?.dismiss();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: white, // Sử dụng nền trắng
                border: Border.all(color: primaryGreen.withValues(alpha: 0.2), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sử dụng logo ứng dụng thay vì icon mặc định
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryGreen.withValues(alpha: 0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'lib/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.home_repair_service,
                          color: primaryGreen,
                          size: 24,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          body,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Thay nút X thành nút "Xem"
                  Container(
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        OverlaySupportEntry.of(context)?.dismiss();
                        onTap?.call();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Xem',
                        style: TextStyle(
                          color: white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      duration: const Duration(seconds: 4),
      position: NotificationPosition.top,
    );
  }

  // Hiển thị thông báo cập nhật trạng thái
  static void showStatusUpdateNotification({
    required String title,
    required String message,
    required String status,
    VoidCallback? onTap,
  }) {
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);

    showOverlayNotification(
      (context) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () {
              OverlaySupportEntry.of(context)?.dismiss();
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: white, // Sử dụng nền trắng
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'lib/images/logo.png',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.home_repair_service,
                                color: primaryGreen,
                                size: 24,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              statusIcon,
                              color: white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Thay nút X thành nút "Xem"
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        OverlaySupportEntry.of(context)?.dismiss();
                        onTap?.call();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Xem',
                        style: TextStyle(
                          color: white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Quicksand',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      duration: const Duration(seconds: 5),
      position: NotificationPosition.top,
    );
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return primaryGreen;
      case 'pending':
      case 'processing':
        return const Color(0xFFFFA726);
      case 'cancelled':
      case 'failed':
        return const Color(0xFFE57373);
      case 'on_way':
      case 'in_progress':
        return const Color(0xFF42A5F5);
      default:
        return primaryGreen;
    }
  }

  static IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.task_alt;
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.refresh;
      case 'cancelled':
        return Icons.cancel;
      case 'failed':
        return Icons.error;
      case 'on_way':
        return Icons.directions_car;
      case 'in_progress':
        return Icons.build;
      default:
        return Icons.notifications;
    }
  }
}
