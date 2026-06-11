import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  Color _color(String name) {
    final map = {
      'Engineering': const Color(0xFF8B5CF6),
      'Product': const Color(0xFF8B5CF6),
      'Design': const Color(0xFF10B981),
      'Marketing': const Color(0xFFF59E0B),
      'HR': const Color(0xFFEF4444),
      'Finance': const Color(0xFF3B82F6),
      'Sales': const Color(0xFFEC4899),
      'Operations': const Color(0xFF06B6D4),
      'Legal': const Color(0xFF8B5CF6),
      'Customer Support': const Color(0xFF10B981),
    };
    return map[name] ?? const Color(0xFF8B5CF6);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, emp, _) {
        final deptCounts = emp.departmentCounts;
        final total = emp.totalCount;

        return Scaffold(
          backgroundColor: AppColors.bg(context),
          appBar: AppBar(
            backgroundColor: AppColors.bg(context),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textMuted(context), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Department Stats',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
          ),
          body: deptCounts.isEmpty
              ? Center(
                  child: Text('No departments yet',
                      style: TextStyle(
                          color: AppColors.textDisabled(context), fontSize: 14)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Employees',
                          value: total.toString(),
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Departments',
                          value: deptCounts.length.toString(),
                          icon: Icons.business_rounded,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    Text('BREAKDOWN',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: AppColors.textDisabled(context))),
                    const SizedBox(height: 12),
                    ...deptCounts.entries.map((e) {
                      final color = _color(e.key);
                      final pct = total == 0 ? 0.0 : e.value / total;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.business_rounded,
                                    color: color, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(e.key,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary(context))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${e.value} ${e.value == 1 ? 'employee' : 'employees'}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 14),
                            Row(children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 7,
                                    backgroundColor:
                                        AppColors.border(context),
                                    valueColor:
                                        AlwaysStoppedAnimation(color),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${(pct * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ]),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                  height: 1.0)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted(context),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}