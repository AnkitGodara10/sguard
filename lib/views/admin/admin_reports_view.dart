// FILE: lib/views/admin/admin_reports_view.dart
//
// PURPOSE:
//   Admin reports screen showing all SL and Leave records system-wide.
//   Admin view format includes "Approved by" (warden name) for Leave records.
//   Supports filtering by date range and hostel.
//   Shows records in the full admin format as specified in the requirements.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/leave_record_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/admin/admin_reports_viewmodel.dart';

class AdminReportsView extends StatelessWidget {
  const AdminReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AdminReportsViewModel>(),
      child: const _AdminReportsContent(),
    );
  }
}

class _AdminReportsContent extends StatefulWidget {
  const _AdminReportsContent();

  @override
  State<_AdminReportsContent> createState() => _AdminReportsContentState();
}

class _AdminReportsContentState extends State<_AdminReportsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReportsViewModel>().loadReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminReportsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reports),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, vm),
            tooltip: 'Filter',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Short Leave (SL)'),
            Tab(text: 'Leave (L)'),
          ],
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _SlReportsTab(records: vm.slRecords),
                _LeaveReportsTab(records: vm.leaveRecords),
              ],
            ),
    );
  }

  void _showFilterSheet(BuildContext context, AdminReportsViewModel vm) {
    final hostelCtrl = TextEditingController(text: vm.hostelFilter ?? '');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Records', style: AppTextStyles.titleLarge),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Hostel Number (optional)',
              hint: 'Filter by hostel',
              controller: hostelCtrl,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppSecondaryButton(
                    label: 'Clear Filters',
                    onPressed: () {
                      vm.setHostelFilter(null);
                      vm.setDateRange(null, null);
                      Navigator.pop(ctx);
                      vm.loadReports();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppPrimaryButton(
                    label: 'Apply',
                    onPressed: () {
                      vm.setHostelFilter(
                        hostelCtrl.text.trim().isEmpty
                            ? null
                            : hostelCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      vm.loadReports();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── SL Reports Tab ─────────────────────────────────────────────────────────────

class _SlReportsTab extends StatelessWidget {
  final List<ShortLeaveRecord> records;

  const _SlReportsTab({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const EmptyState(
        message: 'No short leave records found',
        icon: Icons.timer_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _AdminSlCard(record: records[i]),
    );
  }
}

class _AdminSlCard extends StatelessWidget {
  final ShortLeaveRecord record;

  const _AdminSlCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${record.serialNumber}',
                  style: AppTextStyles.mono.copyWith(
                    color: AppColors.adminColor,
                  ),
                ),
                Text(
                  DateFormatter.displayDate(record.date),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            const Divider(height: 12),
            // Admin SL format: serial#, hostel#, room#, phone,
            // time out, time in, reason
            InfoRow(label: AppStrings.hostelNumber, value: record.hostelNumber),
            InfoRow(label: AppStrings.roomNumber, value: record.roomNumber),
            InfoRow(label: AppStrings.phone, value: record.phone),
            InfoRow(
              label: AppStrings.timeOut,
              value: record.timeOut != null
                  ? DateFormatter.displayTime(record.timeOut!)
                  : '—',
            ),
            InfoRow(
              label: AppStrings.timeIn,
              value: record.timeIn != null
                  ? DateFormatter.displayTime(record.timeIn!)
                  : '—',
            ),
            InfoRow(label: AppStrings.reason, value: record.reason),
          ],
        ),
      ),
    );
  }
}

// ── Leave Reports Tab ──────────────────────────────────────────────────────────

class _LeaveReportsTab extends StatelessWidget {
  final List<LeaveRecord> records;

  const _LeaveReportsTab({required this.records});

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return const EmptyState(
        message: 'No leave records found',
        icon: Icons.event_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _AdminLeaveCard(record: records[i]),
    );
  }
}

class _AdminLeaveCard extends StatelessWidget {
  final LeaveRecord record;

  const _AdminLeaveCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${record.serialNumber}',
                  style: AppTextStyles.mono.copyWith(
                    color: AppColors.adminColor,
                  ),
                ),
                StatusBadge.fromStatus(record.status),
              ],
            ),
            const Divider(height: 12),
            // Admin Leave format: serial#, hostel#, room#, phone,
            // date out + time out, date in + time in, reason, approved by
            InfoRow(label: AppStrings.hostelNumber, value: record.hostelNumber),
            InfoRow(label: AppStrings.roomNumber, value: record.roomNumber),
            InfoRow(label: AppStrings.phone, value: record.phone),
            InfoRow(
              label: AppStrings.dateOut,
              value: record.dateOut != null
                  ? '${DateFormatter.displayDate(record.dateOut!)} '
                        '${DateFormatter.displayTime(record.timeOut!)}'
                  : '—',
            ),
            InfoRow(
              label: AppStrings.dateIn,
              value: record.dateIn != null
                  ? '${DateFormatter.displayDate(record.dateIn!)} '
                        '${DateFormatter.displayTime(record.timeIn!)}'
                  : '—',
            ),
            InfoRow(label: AppStrings.reason, value: record.reason),
            // Admin-only field: who approved
            if (record.approvedByWardenName != null)
              InfoRow(
                label: 'Approved by',
                value: record.approvedByWardenName!,
                icon: Icons.verified_user_outlined,
              ),
          ],
        ),
      ),
    );
  }
}
