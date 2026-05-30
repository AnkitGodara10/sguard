// FILE: lib/views/warden/student_management_view.dart
//
// PURPOSE:
//   Warden screen to browse students in their hostel and update
//   hostel number / room number. Also allows viewing a student's
//   leave records (SL and Leave).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_widgets.dart';
import '../../di/injection.dart';
import '../../models/student_model.dart';
import '../../routes/route_names.dart';
import '../../viewmodels/auth/auth_viewmodel.dart';
import '../../viewmodels/warden/student_management_viewmodel.dart';

class StudentManagementView extends StatelessWidget {
  final String? focusStudentId;

  const StudentManagementView({super.key, this.focusStudentId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<StudentManagementViewModel>(),
      child: _StudentManagementContent(focusStudentId: focusStudentId),
    );
  }
}

class _StudentManagementContent extends StatefulWidget {
  final String? focusStudentId;

  const _StudentManagementContent({this.focusStudentId});

  @override
  State<_StudentManagementContent> createState() =>
      _StudentManagementContentState();
}

class _StudentManagementContentState extends State<_StudentManagementContent> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wardenId = context.read<AuthViewModel>().currentUserId ?? '';
      final vm = context.read<StudentManagementViewModel>();
      vm.loadStudents(wardenId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentManagementViewModel>();

    // Show feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.successMessage != null && mounted) {
        AppSnackbar.showSuccess(context, vm.successMessage!);
        vm.clearMessages();
      }
      if (vm.errorMessage != null && mounted) {
        AppSnackbar.showError(context, vm.errorMessage!);
        vm.clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.studentManagement),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.go(RouteNames.wardenDashboard),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, room, hostel...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          vm.setSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: vm.setSearch,
            ),
          ),

          // Student list
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.filteredStudents.isEmpty
                ? const EmptyState(
                    message: 'No students found',
                    icon: Icons.people_outline,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: vm.filteredStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _StudentTile(
                      student: vm.filteredStudents[i],
                      onTap: () => _showStudentDetail(
                        context,
                        vm,
                        vm.filteredStudents[i],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetail(
    BuildContext context,
    StudentManagementViewModel vm,
    StudentModel student,
  ) {
    vm.selectStudent(student);
    vm.loadStudentRecords(student.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: _StudentDetailSheet(student: student),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.wardenColor.withOpacity(0.1),
          child: Text(
            student.name[0].toUpperCase(),
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.wardenColor,
            ),
          ),
        ),
        title: Text(student.name, style: AppTextStyles.titleSmall),
        subtitle: Text(
          '${student.hostelNumber} · Room ${student.roomNumber}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}

class _StudentDetailSheet extends StatefulWidget {
  final StudentModel student;

  const _StudentDetailSheet({required this.student});

  @override
  State<_StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends State<_StudentDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _hostelController = TextEditingController();
  final _roomController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _hostelController.text = widget.student.hostelNumber;
    _roomController.text = widget.student.roomNumber;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hostelController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StudentManagementViewModel>();
    final student = vm.selectedStudent ?? widget.student;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: AppTextStyles.titleLarge),
                      Text(
                        '${student.hostelNumber} · Room ${student.roomNumber}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                ),
              ],
            ),
          ),

          // Edit form (warden can only change hostel + room)
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'New Hostel',
                      controller: _hostelController,
                      validator: Validators.hostelNumber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'New Room',
                      controller: _roomController,
                      validator: Validators.roomNumber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppPrimaryButton(
                    label: AppStrings.save,
                    width: 70,
                    isLoading: vm.isLoading,
                    onPressed: () async {
                      final success = await vm.updateStudentHostelRoom(
                        student.id,
                        hostelNumber: _hostelController.text.trim(),
                        roomNumber: _roomController.text.trim(),
                      );
                      if (success && mounted) {
                        setState(() => _isEditing = false);
                      }
                    },
                  ),
                ],
              ),
            ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'SL Records'),
              Tab(text: 'Leave Records'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Info tab
                ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    InfoRow(label: 'Name', value: student.name),
                    InfoRow(label: 'Phone', value: student.phone),
                    InfoRow(label: 'Email', value: student.email),
                    InfoRow(label: 'Hostel', value: student.hostelNumber),
                    InfoRow(label: 'Room', value: student.roomNumber),
                    if (student.fathersName != null)
                      InfoRow(
                        label: "Father's Name",
                        value: student.fathersName!,
                      ),
                    if (student.fathersPhone != null)
                      InfoRow(
                        label: "Father's Phone",
                        value: student.fathersPhone!,
                      ),
                  ],
                ),

                // SL Records tab — warden format
                ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.selectedStudentSlRecords.length,
                  itemBuilder: (_, i) {
                    final r = vm.selectedStudentSlRecords[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Warden SL format: serial#, hostel, room, phone,
                            // time out, time in, reason
                            InfoRow(
                              label: AppStrings.serialNumber,
                              value: '#${r.serialNumber}',
                            ),
                            InfoRow(
                              label: AppStrings.timeOut,
                              value: r.timeOut != null
                                  ? DateFormatter.displayTime(r.timeOut!)
                                  : '—',
                            ),
                            InfoRow(
                              label: AppStrings.timeIn,
                              value: r.timeIn != null
                                  ? DateFormatter.displayTime(r.timeIn!)
                                  : '—',
                            ),
                            InfoRow(label: AppStrings.reason, value: r.reason),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Leave Records tab — warden format
                ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.selectedStudentLeaveRecords.length,
                  itemBuilder: (_, i) {
                    final r = vm.selectedStudentLeaveRecords[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InfoRow(
                              label: AppStrings.serialNumber,
                              value: '#${r.serialNumber}',
                            ),
                            InfoRow(
                              label: AppStrings.dateOut,
                              value: r.dateOut != null
                                  ? DateFormatter.displayDateTime(r.dateOut!)
                                  : '—',
                            ),
                            InfoRow(
                              label: AppStrings.dateIn,
                              value: r.dateIn != null
                                  ? DateFormatter.displayDateTime(r.dateIn!)
                                  : '—',
                            ),
                            InfoRow(label: AppStrings.reason, value: r.reason),
                            StatusBadge.fromStatus(r.status),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
