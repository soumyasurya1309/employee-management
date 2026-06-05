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
    _joiningDateController.text =
        DateFormat('dd/MM/yyyy').format(e.joiningDate);
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _joiningDate = picked;
        _joiningDateController.text =
            DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_joiningDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the joining date'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit
              ? '${employee.name} updated successfully'
              : '${employee.name} added successfully'),
          backgroundColor: AppTheme.secondaryColor,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Operation failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
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
            backgroundColor: AppTheme.surfaceColor,
            appBar: AppBar(
              title: Text(_isEdit ? 'Edit Employee' : 'Add Employee'),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionCard(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          hint: 'John Doe',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) =>
                              AppValidators.validateRequired(v, 'Name'),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Employee ID',
                          hint: 'EMP001',
                          controller: _employeeIdController,
                          prefixIcon: const Icon(Icons.badge_outlined),
                          validator: (v) =>
                              AppValidators.validateRequired(v, 'Employee ID'),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Address',
                          hint: '123 Main St, City, Country',
                          controller: _addressController,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          maxLines: 2,
                          validator: (v) =>
                              AppValidators.validateRequired(v, 'Address'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Contact Information',
                      icon: Icons.contact_mail_outlined,
                      children: [
                        AppTextField(
                          label: 'Email Address',
                          hint: 'john@company.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: AppValidators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Phone Number',
                          hint: '10-digit number',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: AppValidators.validatePhone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Job Information',
                      icon: Icons.work_outline_rounded,
                      children: [
                        _dropdownField(
                          label: 'Department',
                          value: _selectedDepartment,
                          items: AppConstants.departments,
                          icon: Icons.business_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedDepartment = v),
                          validator: (v) => v == null
                              ? 'Please select a department'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _dropdownField(
                          label: 'Designation',
                          value: _selectedDesignation,
                          items: AppConstants.designations,
                          icon: Icons.work_history_outlined,
                          onChanged: (v) =>
                              setState(() => _selectedDesignation = v),
                          validator: (v) => v == null
                              ? 'Please select a designation'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Salary (USD)',
                          hint: '50000',
                          controller: _salaryController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          prefixIcon: const Icon(Icons.attach_money),
                          validator: AppValidators.validateSalary,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Joining Date',
                          hint: 'Select date',
                          controller: _joiningDateController,
                          readOnly: true,
                          onTap: _pickDate,
                          prefixIcon:
                              const Icon(Icons.calendar_today_outlined),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          validator: (v) =>
                              AppValidators.validateRequired(v, 'Joining date'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: Icon(
                            _isEdit ? Icons.save_outlined : Icons.person_add_alt_1),
                        label: Text(_isEdit ? 'Save Changes' : 'Add Employee'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212529),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }
}
