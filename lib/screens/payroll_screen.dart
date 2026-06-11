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
          backgroundColor: AppColors.bg(context),
          appBar: AppBar(
            backgroundColor: AppColors.bg(context),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.textMuted(context), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Total Payroll',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
          ),
          body: employees.isEmpty
              ? Center(
                  child: Text('No employees found',
                      style: TextStyle(
                          color: AppColors.textDisabled(context), fontSize: 14)),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Total banner — gradient always looks good on both themes
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
                    Text('EMPLOYEES',
                        style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            color: AppColors.textDisabled(context))),
                    const SizedBox(height: 12),
                    ...employees.map((e) {
                      final joining =
                          '${e.joiningDate.day}/${e.joiningDate.month}/${e.joiningDate.year}';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border(context)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
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
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary(context))),
                                const SizedBox(height: 3),
                                Row(children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 11,
                                      color: AppColors.textDisabled(context)),
                                  const SizedBox(width: 4),
                                  Text('Joined $joining',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textDisabled(context))),
                                  const SizedBox(width: 10),
                                  Icon(Icons.business_rounded,
                                      size: 11,
                                      color: AppColors.textDisabled(context)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      e.department,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textDisabled(context)),
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
                              Text('/ month',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textDisabled(context))),
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