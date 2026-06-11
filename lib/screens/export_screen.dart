import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' hide Border;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/employee_provider.dart';
import '../widgets/common_widgets.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _exportingPdf = false;
  bool _exportingExcel = false;

  Future<void> _exportPdf(EmployeeProvider emp) async {
    setState(() => _exportingPdf = true);
    try {
      final font = pw.Font.courier();
      final boldFont = pw.Font.courierBold();

      final pdf = pw.Document();
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text('Employee Report',
                style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Total Employees: ${emp.totalCount}',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text(
                'Total Payroll: \$${(emp.totalSalary / 1000).toStringAsFixed(1)}k',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.Text(
                'Avg Salary: \$${(emp.averageSalary / 1000).toStringAsFixed(1)}k',
                style: pw.TextStyle(font: font, fontSize: 12)),
            pw.SizedBox(height: 16),
            // FIX: replaced deprecated Table.fromTextArray with TableHelper.fromTextArray
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Department', 'Salary', 'Joining Date'],
              data: emp.employees.map((e) {
                // FIX: joiningDate is non-nullable — removed null check and ! operators
                final joining =
                    '${e.joiningDate.day}/${e.joiningDate.month}/${e.joiningDate.year}';
                return [
                  e.name,
                  // FIX: department is non-nullable — removed ?? 'N/A'
                  e.department,
                  '\$${e.salary.toStringAsFixed(0)}',
                  joining,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                  font: boldFont, fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.indigo),
              headerAlignment: pw.Alignment.centerLeft,
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: pw.TextStyle(font: font, fontSize: 11),
            ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/employee_report.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Employee Report PDF',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    }
    if (mounted) setState(() => _exportingPdf = false);
  }

  Future<void> _exportExcel(EmployeeProvider emp) async {
    setState(() => _exportingExcel = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Employees'];

      sheet.appendRow([
        TextCellValue('Name'),
        TextCellValue('Department'),
        TextCellValue('Salary'),
        TextCellValue('Joining Date'),
        TextCellValue('Email'),
      ]);

      for (final e in emp.employees) {
        // FIX: joiningDate is non-nullable — removed null check and ! operators
        final joining =
            '${e.joiningDate.day}/${e.joiningDate.month}/${e.joiningDate.year}';
        sheet.appendRow([
          TextCellValue(e.name),
          // FIX: department is non-nullable — removed ?? 'N/A'
          TextCellValue(e.department),
          TextCellValue('\$${e.salary.toStringAsFixed(0)}'),
          TextCellValue(joining),
          // FIX: email is non-nullable — removed ?? 'N/A'
          TextCellValue(e.email),
        ]);
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/employee_report.xlsx');
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Employee Report Excel',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting Excel: $e')),
        );
      }
    }
    if (mounted) setState(() => _exportingExcel = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, emp, _) {
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
            title: const Text('Export Reports',
                style: TextStyle(
                    color: DarkColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Report Summary',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _StatPill(
                          label: 'Employees',
                          value: emp.totalCount.toString()),
                      const SizedBox(width: 10),
                      _StatPill(
                          label: 'Departments',
                          value: emp.departmentCounts.length.toString()),
                      const SizedBox(width: 10),
                      _StatPill(
                          label: 'Payroll',
                          value:
                              '\$${(emp.totalSalary / 1000).toStringAsFixed(0)}k'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('EXPORT OPTIONS',
                  style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.8,
                      color: DarkColors.textDisabled)),
              const SizedBox(height: 12),
              _ExportCard(
                icon: Icons.picture_as_pdf_rounded,
                color: const Color(0xFFEF4444),
                title: 'Export as PDF',
                subtitle: 'Employee list with salary & joining date',
                loading: _exportingPdf,
                onTap: () => _exportPdf(emp),
              ),
              const SizedBox(height: 12),
              _ExportCard(
                icon: Icons.table_chart_rounded,
                color: const Color(0xFF10B981),
                title: 'Export as Excel / CSV',
                subtitle: 'Spreadsheet with all employee data',
                loading: _exportingExcel,
                onTap: () => _exportExcel(emp),
              ),
              const SizedBox(height: 12),
              _ExportCard(
                icon: Icons.share_rounded,
                color: const Color(0xFF3B82F6),
                title: 'Share via WhatsApp / Email',
                subtitle: 'Share PDF report directly',
                loading: false,
                onTap: () => _exportPdf(emp),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }
}

class _ExportCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool loading;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.loading,
    required this.onTap,
  });

  @override
  State<_ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends State<_ExportCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.loading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.12)
                : DarkColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.4)
                  : DarkColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: widget.loading
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: widget.color),
                    )
                  : Icon(widget.icon, color: widget.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: DarkColors.textPrimary)),
                  const SizedBox(height: 3),
                  Text(widget.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: DarkColors.textDisabled)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: widget.color.withValues(alpha: 0.5), size: 14),
          ]),
        ),
      ),
    );
  }
}