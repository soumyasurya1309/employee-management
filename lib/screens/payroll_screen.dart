import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, emp, _) {
        final employees = emp.employees;
        final totalSalary = emp.totalSalary;

        return Scaffold(
          backgroundColor: DarkColors.bg,
          appBar: AppBar(
            backgroundColor: DarkColors.bg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: DarkColors.textMuted, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Total Payroll',
                style: TextStyle(
                    color: DarkColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
          ),
          body: employees.isEmpty
              ? const Center(
                  child: Text('No employees found',
                      style: TextStyle(
                          color: DarkColors.textDisabled, fontSize: 14)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Total banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7F1D1D), Color(0xFFEF4444)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Monthly Payroll',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          Text(
                            '\$${(totalSalary / 1000).toStringAsFixed(1)}k',
                            style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0),
                          ),
                          const SizedBox(height: 4),
                          Text('${employees.length} employees',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white60)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('EMPLOYEES',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: DarkColors.textDisabled)),
                    const SizedBox(height: 12),
                    ...employees.map((e) {
                      // FIX: joiningDate is non-nullable — removed unnecessary null check
                      final joining =
                          '${e.joiningDate.day}/${e.joiningDate.month}/${e.joiningDate.year}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DarkColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: DarkColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                e.name.isNotEmpty
                                    ? e.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF4444)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.name,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: DarkColors.textPrimary)),
                                const SizedBox(height: 3),
                                Row(children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      size: 11,
                                      color: DarkColors.textDisabled),
                                  const SizedBox(width: 4),
                                  Text('Joined $joining',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: DarkColors.textDisabled)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.business_rounded,
                                      size: 11,
                                      color: DarkColors.textDisabled),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      // FIX: department is non-nullable — removed ?? 'N/A'
                                      e.department,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: DarkColors.textDisabled),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(e.salary / 1000).toStringAsFixed(1)}k',
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF4444)),
                              ),
                              const Text('/ month',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: DarkColors.textDisabled)),
                            ],
                          ),
                        ]),
                      );
                    }),
                  ],
                ),
        );
      },
    );
  }
}