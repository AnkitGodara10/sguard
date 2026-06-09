import 'package:flutter/material.dart';
import 'package:sguard/core/constants/app_colors.dart';
import 'package:sguard/core/constants/app_strings.dart';
import 'package:sguard/core/constants/app_text_styles.dart';
import 'package:sguard/core/utils/date_formatter.dart';
import 'package:sguard/models/leave_record_model.dart';

class LeaveStatusCard extends StatelessWidget {
  final LeaveRecordModel leave;
  final VoidCallback? onTap;

  const LeaveStatusCard({super.key, required this.leave, this.onTap});

  Color get _statusColor {
    switch (leave.status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      case 'completed':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    switch (leave.status.toLowerCase()) {
      case 'approved':
        return AppStrings.statusApproved;
      case 'pending':
        return AppStrings.statusPending;
      case 'rejected':
        return AppStrings.statusRejected;
      case 'completed':
        return AppStrings.statusCompleted;
      default:
        return leave.status;
    }
  }

  IconData get _statusIcon {
    switch (leave.status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(
                    label: _statusLabel,
                    color: _statusColor,
                    icon: _statusIcon,
                  ),
                  const Spacer(),
                  Text(
                    DateFormatter.displayDate(leave.fromDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                leave.reason,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${DateFormatter.displayDate(leave.fromDate)} – ${DateFormatter.displayDate(leave.toDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (onTap != null) ...[
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
