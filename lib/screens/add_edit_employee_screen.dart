import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/employee.dart';
import '../providers/employee_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/common_widgets.dart';

class AddEditEmployeeScreen extends StatefulWidget {
  const AddEditEmployeeScreen({super.key});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEdit = false;
  Employee? _existingEmployee;

  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _salaryController = TextEditingController();
  final _addressController = TextEditingController();
  final _joiningDateController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedDesignation;
  DateTime? _joiningDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Employee && !_isEdit) {
      _isEdit = true;
      _existingEmployee = args;
      _populateFields(args);
    }
  }

  void _populateFields(Employee e) {
    _nameController.text = e.name;
    _employeeIdController.text = e.employeeId;
    _emailController.text = e.email;
    _phoneController.text = e.phone;
    _salaryController.text = e.salary.toString();
    _addressController.text = e.address;
    _joiningDate = e.joiningDate;
    _joiningDateController.text = DateFormat('dd/MM/yyyy').format(e.joiningDate);
    _selectedDepartment = e.department;
    _selectedDesignation = e.designation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    _addressController.dispose();
    _joiningDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final scheme = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: scheme.copyWith(primary: AppColors.accent),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _joiningDate = picked;
        _joiningDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_joiningDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select the joining date'),
        backgroundColor: Color(0xFFF87171),
      ));
      return;
    }
    final provider = context.read<EmployeeProvider>();
    final employee = Employee(
      id: _existingEmployee?.id ?? '',
      name: _nameController.text.trim(),
      employeeId: _employeeIdController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().replaceAll(RegExp(r'\D'), ''),
      department: _selectedDepartment!,
      designation: _selectedDesignation!,
      salary: double.parse(_salaryController.text.trim()),
      joiningDate: _joiningDate!,
      address: _addressController.text.trim(),
      createdAt: _existingEmployee?.createdAt ?? DateTime.now(),
    );

    bool success;
    if (_isEdit) {
      success = await provider.updateEmployee(employee);
    } else {
      success = await provider.addEmployee(employee);
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit
            ? '${employee.name} updated'
            : '${employee.name} added'),
        backgroundColor: const Color(0xFF34D399),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(provider.errorMessage ?? 'Operation failed'),
        backgroundColor: const Color(0xFFF87171),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      provider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmployeeProvider>(
      builder: (context, provider, _) {
        return LoadingOverlay(
          isLoading: provider.status == EmployeeStatus.loading,
          child: Scaffold(
            backgroundColor: AppColors.bg(context),
            appBar: AppBar(
              backgroundColor: AppColors.bg(context),
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.textSecondary(context)),
              title: Text(
                _isEdit ? 'Edit employee' : 'Add employee',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Section(
                      title: 'PERSONAL INFO',
                      icon: Icons.person_outline_rounded,
                      children: [
                        AppTextField(
                          label: 'Full name',
                          hint: 'John Doe',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Employee ID',
                          hint: 'EMP001',
                          controller: _employeeIdController,
                          prefixIcon: const Icon(Icons.badge_outlined),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Address',
                          hint: '123 Main St, City',
                          controller: _addressController,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          maxLines: 2,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Section(
                      title: 'CONTACT INFO',
                      icon: Icons.mail_outline_rounded,
                      children: [
                        AppTextField(
                          label: 'Email address',
                          hint: 'john@company.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          validator: AppValidators.validateEmail,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Phone number',
                          hint: '10-digit number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: AppValidators.validatePhone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _Section(
                      title: 'JOB INFO',
                      icon: Icons.work_outline_rounded,
                      children: [
                        _AppDropdown(
                          label: 'Department',
                          value: _selectedDepartment,
                          items: AppConstants.departments,
                          icon: Icons.business_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedDepartment = v),
                          validator: (v) =>
                              v == null ? 'Select department' : null,
                        ),
                        const SizedBox(height: 12),
                        _AppDropdown(
                          label: 'Designation',
                          value: _selectedDesignation,
                          items: AppConstants.designations,
                          icon: Icons.work_history_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedDesignation = v),
                          validator: (v) =>
                              v == null ? 'Select designation' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Salary (₹)',
                          hint: '50000',
                          controller: _salaryController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefixIcon: const Icon(Icons.currency_rupee),
                          validator: AppValidators.validateSalary,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          label: 'Joining date',
                          hint: 'Select date',
                          controller: _joiningDateController,
                          readOnly: true,
                          onTap: _pickDate,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Select date'
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GradientButton(
                      label: _isEdit ? 'Save changes' : 'Add employee',
                      icon: _isEdit
                          ? Icons.save_outlined
                          : Icons.person_add_alt_1_rounded,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
            Icon(icon, size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(title,
                style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted(context))),
          ]),
          const SizedBox(height: 2),
          Divider(color: AppColors.border(context), height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _AppDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final IconData icon;
  final void Function(String?) onChanged;
  final String? Function(String?) validator;

  const _AppDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          validator: validator,
          dropdownColor: AppColors.surface(context),
          style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14),
          icon: Icon(Icons.arrow_drop_down, color: AppColors.textMuted(context)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.accent, size: 18),
            filled: true,
            fillColor: AppColors.bg(context),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
          isExpanded: true,
          items: items
              .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item,
                      style: TextStyle(
                          color: AppColors.textPrimary(context), fontSize: 13))))
              .toList(),
        ),
      ],
    );
  }
}