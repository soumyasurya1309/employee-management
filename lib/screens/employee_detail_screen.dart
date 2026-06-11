import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employee = ModalRoute.of(context)!.settings.arguments as Employee;
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, employee, isAdmin),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoCard(context, employee),
                  const SizedBox(height: 10),
                  _buildContactCard(context, employee),
                  const SizedBox(height: 10),
                  _buildJobCard(context, employee),
                  const SizedBox(height: 10),
                  if (isAdmin) _buildActionButtons(context, employee),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, Employee employee, bool isAdmin) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.bg(context),
      iconTheme: IconThemeData(color: AppColors.textSecondary(context)),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF13103A)
                : const Color(0xFFEEF2FF),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              AvatarInitials(name: employee.name, radius: 38, fontSize: 24),
              const SizedBox(height: 12),
              Text(
                employee.name,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${employee.designation} • ${employee.department}',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.accent, size: 20),
            onPressed: () => Navigator.pushNamed(
              context,
              '/employees/edit',
              arguments: employee,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, Employee employee) {
    return _Section(
      title: 'EMPLOYEE INFO',
      icon: Icons.badge_outlined,
      children: [
        _InfoRow('Employee ID', employee.employeeId),
        _InfoRow('Joining Date',
            DateFormat('MMMM dd, yyyy').format(employee.joiningDate)),
        _InfoRow('Salary', formatCurrency(employee.salary),
            valueColor: const Color(0xFF34D399)),
        _InfoRow('Address', employee.address, isLast: true),
      ],
    );
  }

  Widget _buildContactCard(BuildContext context, Employee employee) {
    return _Section(
      title: 'CONTACT DETAILS',
      icon: Icons.mail_outline_rounded,
      children: [
        _InfoRow('Email', employee.email),
        _InfoRow('Phone', employee.phone, isLast: true),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, Employee employee) {
    return _Section(
      title: 'JOB DETAILS',
      icon: Icons.work_outline_rounded,
      children: [
        _InfoRow('Department', employee.department),
        _InfoRow('Designation', employee.designation),
        _InfoRow('Member Since',
            DateFormat('MMM yyyy').format(employee.createdAt),
            isLast: true),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Employee employee) {
    return Row(children: [
      Expanded(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/employees/edit',
            arguments: employee,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, color: AppColors.accent, size: 16),
                SizedBox(width: 6),
                Text('Edit',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: GestureDetector(
          onTap: () => _confirmDelete(context, employee),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFFF87171).withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline, color: Color(0xFFF87171), size: 16),
                SizedBox(width: 6),
                Text('Delete',
                    style: TextStyle(
                        color: Color(0xFFF87171),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Future<void> _confirmDelete(
      BuildContext context, Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(ctx),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete employee',
            style: TextStyle(
                color: AppColors.textPrimary(ctx), fontSize: 16)),
        content: Text('Remove ${employee.name}? This cannot be undone.',
            style: TextStyle(
                color: AppColors.textSecondary(ctx), fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textSecondary(ctx)))),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, true),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Delete',
                  style: TextStyle(
                      color: Color(0xFFF87171), fontSize: 13)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final provider = context.read<EmployeeProvider>();
      final success = await provider.deleteEmployee(employee);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? '${employee.name} removed'
            : provider.errorMessage ?? 'Delete failed'),
        backgroundColor: success
            ? const Color(0xFF34D399)
            : const Color(0xFFF87171),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ));
      if (success) Navigator.pop(context);
      if (!success) provider.clearError();
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _Section(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted(context))),
          ]),
          Divider(color: AppColors.border(context), height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _InfoRow(this.label, this.value,
      {this.valueColor, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context))),
              ),
              Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? AppColors.textPrimary(context))),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: AppColors.border(context), height: 1),
      ],
    );
  }
}