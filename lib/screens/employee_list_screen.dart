import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/auth_provider.dart';
import '../providers/employee_provider.dart';
import '../utils/app_theme.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only admins can delete employees.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Are you sure you want to delete ${employee.name}? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final provider = context.read<EmployeeProvider>();
      final success = await provider.deleteEmployee(employee);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '${employee.name} deleted successfully'
              : provider.errorMessage ?? 'Delete failed'),
          backgroundColor:
              success ? AppTheme.secondaryColor : AppTheme.errorColor,
        ),
      );
      if (!success) provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          appBar: AppBar(
            title: Text('Employees (${provider.totalCount})'),
            actions: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    label: const Text('Admin',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12)),
                    backgroundColor: AppTheme.secondaryColor,
                  ),
                ),
            ],
          ),
          floatingActionButton: isAdmin
              ? FloatingActionButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/employees/add'),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.person_add_alt_1_rounded),
                )
              : null,
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: provider.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, email, department...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.clearSearch();
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: _buildBody(provider, isAdmin),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(EmployeeProvider provider, bool isAdmin) {
    if (provider.status == EmployeeStatus.loading &&
        provider.allEmployees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: employees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final employee = employees[index];
        return Slidable(
          key: ValueKey(employee.id),
          endActionPane: isAdmin
              ? ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => Navigator.pushNamed(
                        context,
                        '/employees/edit',
                        arguments: employee,
                      ),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      icon: Icons.edit_outlined,
                      label: 'Edit',
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)),
                    ),
                    SlidableAction(
                      onPressed: (_) => _confirmDelete(employee),
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(12)),
                    ),
                  ],
                )
              : null,
          child: _EmployeeCard(
            employee: employee,
            isAdmin: isAdmin,
            onTap: () => Navigator.pushNamed(
              context,
              '/employees/detail',
              arguments: employee,
            ),
            onEdit: isAdmin
                ? () => Navigator.pushNamed(
                      context,
                      '/employees/edit',
                      arguments: employee,
                    )
                : null,
            onDelete: isAdmin ? () => _confirmDelete(employee) : null,
          ),
        );
      },
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _EmployeeCard({
    required this.employee,
    required this.isAdmin,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AvatarInitials(name: employee.name, radius: 26, fontSize: 17),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ),
                        Text(
                          formatCurrency(employee.salary),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.designation,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6C757D)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        DepartmentBadge(department: employee.department),
                        const Spacer(),
                        Text(
                          'ID: ${employee.employeeId}',
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6C757D)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}