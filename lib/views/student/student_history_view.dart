// FILE: lib/views/student/student_history_view.dart
//
// PURPOSE:
//   Shows the student's leave history in two tabs: SL (last 30 days)
//   and Leave (last 6 months). Displays records in the format specified
//   in the requirements: date, time out, time in, reason for SL;
//   date out, date in, time out, time in, reason for Leave.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

//import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/leave_record_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/student/student_history_viewmodel.dart';

class StudentHistoryView extends StatelessWidget {
  const StudentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<StudentHistoryViewModel>(),
      child: const _StudentHistoryContent(),
    );
  }
}

class _StudentHistoryContent extends StatefulWidget {
  const _StudentHistoryContent();

  @override
  State<_StudentHistoryContent> createState() => _StudentHistoryContentState();
}

class _StudentHistoryContentState extends State<_StudentHistoryContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentId = context.read<AuthViewModel>().currentUserId ?? '';
      context.read<StudentHistoryViewModel>().loadHistory(studentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentHistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaveHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.studentDashboard),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: vm.setTab,
          tabs: const [
            Tab(text: 'Short Leave (SL)'),
            Tab(text: 'Leave (L)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SlHistoryTab(vm: vm),
          _LeaveHistoryTab(vm: vm),
        ],
      ),
    );
  }
}

// ── SL History Tab ─────────────────────────────────────────────────────────────

class _SlHistoryTab extends StatelessWidget {
  final StudentHistoryViewModel vm;

  const _SlHistoryTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingSl) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.slError != null) {
      return ErrorDisplay(message: vm.slError!);
    }
    if (vm.slRecords.isEmpty) {
      return const EmptyState(
        message: 'No short leave records in the last 30 days',
        icon: Icons.timer_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        final studentId = context.read<AuthViewModel>().currentUserId ?? '';
        return context.read<StudentHistoryViewModel>().refresh(studentId);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.slRecords.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _SlRecordCard(record: vm.slRecords[i]),
      ),
    );
  }
}

class _SlRecordCard extends StatelessWidget {
  final ShortLeaveRecord record;

  const _SlRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.displayDate(record.date),
                  style: AppTextStyles.titleSmall,
                ),
                StatusBadge.fromStatus(record.status),
              ],
            ),
            const Divider(height: 16),
            // Student view: date, time out, time in, reason
            InfoRow(
              label: AppStrings.timeOut,
              value: record.timeOut != null
                  ? DateFormatter.displayTime(record.timeOut!)
                  : '—',
              icon: Icons.logout,
            ),
            InfoRow(
              label: AppStrings.timeIn,
              value: record.timeIn != null
                  ? DateFormatter.displayTime(record.timeIn!)
                  : '—',
              icon: Icons.login,
            ),
            InfoRow(
              label: AppStrings.reason,
              value: record.reason,
              icon: Icons.note_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Leave History Tab ──────────────────────────────────────────────────────────

class _LeaveHistoryTab extends StatelessWidget {
  final StudentHistoryViewModel vm;

  const _LeaveHistoryTab({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isLoadingLeave) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.leaveError != null) {
      return ErrorDisplay(message: vm.leaveError!);
    }
    if (vm.leaveRecords.isEmpty) {
      return const EmptyState(
        message: 'No leave records in the last 6 months',
        icon: Icons.event_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        final studentId = context.read<AuthViewModel>().currentUserId ?? '';
        return context.read<StudentHistoryViewModel>().refresh(studentId);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vm.leaveRecords.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) => _LeaveRecordCard(record: vm.leaveRecords[i]),
      ),
    );
  }
}

class _LeaveRecordCard extends StatelessWidget {
  final LeaveRecord record;

  const _LeaveRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leave Request', style: AppTextStyles.titleSmall),
                StatusBadge.fromStatus(record.status),
              ],
            ),
            const Divider(height: 16),
            // Student view: date out + time out, date in + time in, reason
            InfoRow(
              label: AppStrings.dateOut,
              value: record.dateOut != null
                  ? '${DateFormatter.displayDate(record.dateOut!)} '
                        '${DateFormatter.displayTime(record.timeOut!)}'
                  : '—',
              icon: Icons.logout,
            ),
            InfoRow(
              label: AppStrings.dateIn,
              value: record.dateIn != null
                  ? '${DateFormatter.displayDate(record.dateIn!)} '
                        '${DateFormatter.displayTime(record.timeIn!)}'
                  : '—',
              icon: Icons.login,
            ),
            InfoRow(
              label: AppStrings.reason,
              value: record.reason,
              icon: Icons.note_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
