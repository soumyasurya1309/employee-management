import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(Employee employee) async {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    if (!isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Only admins can delete employees.'),
        backgroundColor: Color(0xFFF87171),
      ));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(ctx),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete employee',
            style: TextStyle(color: AppColors.textPrimary(ctx), fontSize: 16)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Delete',
                  style: TextStyle(color: Color(0xFFF87171), fontSize: 13)),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final provider = context.read<EmployeeProvider>();
      final success = await provider.deleteEmployee(employee);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? '${employee.name} removed'
            : provider.errorMessage ?? 'Delete failed'),
        backgroundColor: success
            ? const Color(0xFF34D399)
            : const Color(0xFFF87171),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      if (!success) provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.bg(context),
          appBar: AppBar(
            backgroundColor: AppColors.bg(context),
            elevation: 0,
            title: Text('Employees (${provider.totalCount})',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
            actions: [
              // ── QR Scanner Button ──
              IconButton(
                icon: Icon(Icons.qr_code_scanner_rounded,
                    color: AppColors.textMuted(context), size: 22),
                tooltip: 'Scan Employee QR',
                onPressed: () =>
                    Navigator.pushNamed(context, '/qr-scanner'),
              ),
              if (isAdmin)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFF34D399)),
                  ),
                  child: const Text('Admin',
                      style: TextStyle(
                          color: Color(0xFF34D399), fontSize: 11)),
                ),
            ],
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/employees/add'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: AppColors.accent,
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white),
                )
              : null,
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  style: TextStyle(
                      color: AppColors.textPrimary(context), fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search name, ID, department...',
                    hintStyle: TextStyle(
                        color: AppColors.textMuted(context), fontSize: 13),
                    prefixIcon: Icon(Icons.search,
                        color: AppColors.textMuted(context), size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: AppColors.textMuted(context),
                                size: 16),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildBody(provider, isAdmin)),
          ]),
        );
      },
    );
  }

  Widget _buildBody(EmployeeProvider provider, bool isAdmin) {
    if (provider.status == EmployeeStatus.loading &&
        provider.allEmployees.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (provider.status == EmployeeStatus.error &&
        provider.allEmployees.isEmpty) {
      return EmptyState(
        title: 'Something went wrong',
        subtitle: provider.errorMessage ?? 'Failed to load employees',
        icon: Icons.error_outline_rounded,
        buttonLabel: 'Retry',
        onButtonPressed: () {
          provider.clearError();
          provider.startListening();
        },
      );
    }
    final employees = provider.employees;
    if (employees.isEmpty) {
      return EmptyState(
        title: provider.searchQuery.isNotEmpty
            ? 'No results found'
            : 'No employees yet',
        subtitle: provider.searchQuery.isNotEmpty
            ? 'Try a different search term'
            : 'Add your first employee to get started',
        icon: Icons.people_alt_outlined,
        buttonLabel:
            provider.searchQuery.isEmpty && isAdmin ? 'Add Employee' : null,
        onButtonPressed: provider.searchQuery.isEmpty && isAdmin
            ? () => Navigator.pushNamed(context, '/employees/add')
            : null,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Slidable(
            key: ValueKey(emp.id),
            endActionPane: isAdmin
                ? ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) => Navigator.pushNamed(
                            context, '/employees/edit',
                            arguments: emp),
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12)),
                      ),
                      SlidableAction(
                        onPressed: (_) => _confirmDelete(emp),
                        backgroundColor: const Color(0xFFF87171),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12)),
                      ),
                    ],
                  )
                : null,
            child: _EmpCard(
              employee: emp,
              onTap: () => Navigator.pushNamed(
                  context, '/employees/detail',
                  arguments: emp),
              onEdit: isAdmin
                  ? () => Navigator.pushNamed(
                      context, '/employees/edit',
                      arguments: emp)
                  : null,
              onDelete: isAdmin ? () => _confirmDelete(emp) : null,
            ),
          ),
        );
      },
    );
  }
}

class _EmpCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _EmpCard({
    required this.employee,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(children: [
          AvatarInitials(name: employee.name, radius: 20, fontSize: 13),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(employee.name,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary(context))),
                  ),
                  Text(formatCurrency(employee.salary),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent)),
                ]),
                const SizedBox(height: 2),
                Text(employee.designation,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary(context))),
                const SizedBox(height: 6),
                Row(children: [
                  DepartmentBadge(department: employee.department),
                  const Spacer(),
                  Text('ID: ${employee.employeeId}',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted(context))),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted(context), size: 18),
        ]),
      ),
    );
  }
}