import 'dart:async';
import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../services/notification_service.dart';

enum EmployeeStatus { initial, loading, loaded, error }

class EmployeeProvider extends ChangeNotifier {
  final EmployeeService _service = EmployeeService();
  final NotificationService _notifications = NotificationService();

  List<Employee> _employees = [];
  EmployeeStatus _status = EmployeeStatus.initial;
  String? _errorMessage;
  String _searchQuery = '';
  StreamSubscription<List<Employee>>? _subscription;

  List<Employee> get employees => _filteredEmployees;
  List<Employee> get allEmployees => _employees;
  EmployeeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get totalCount => _employees.length;

  Map<String, int> get departmentCounts {
    final map = <String, int>{};
    for (final e in _employees) {
      map[e.department] = (map[e.department] ?? 0) + 1;
    }
    return map;
  }

  double get totalSalary =>
      _employees.fold(0.0, (sum, e) => sum + e.salary);

  double get averageSalary =>
      _employees.isEmpty ? 0 : totalSalary / _employees.length;

  List<Employee> get _filteredEmployees {
    if (_searchQuery.isEmpty) return _employees;
    final q = _searchQuery.toLowerCase();
    return _employees.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.employeeId.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q) ||
          e.department.toLowerCase().contains(q) ||
          e.designation.toLowerCase().contains(q);
    }).toList();
  }

  void startListening() {
    _status = EmployeeStatus.loading;
    notifyListeners();
    _subscription = _service.getEmployeesStream().listen(
      (employees) {
        _employees = employees;
        _status = EmployeeStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _status = EmployeeStatus.error;
        _errorMessage = 'Failed to load employees: $e';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<bool> addEmployee(Employee employee) async {
    try {
      _status = EmployeeStatus.loading;
      notifyListeners();

      final isIdUnique = await _service.isEmployeeIdUnique(employee.employeeId);
      if (!isIdUnique) {
        _errorMessage = 'Employee ID "${employee.employeeId}" is already in use.';
        _status = EmployeeStatus.error;
        notifyListeners();
        return false;
      }

      final isEmailUnique = await _service.isEmailUnique(employee.email);
      if (!isEmailUnique) {
        _errorMessage = 'Email "${employee.email}" is already registered.';
        _status = EmployeeStatus.error;
        notifyListeners();
        return false;
      }

      await _service.addEmployee(employee);
      await _notifications.notifyEmployeeAdded(employee.name);
      _status = EmployeeStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add employee: $e';
      _status = EmployeeStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEmployee(Employee employee) async {
    try {
      _status = EmployeeStatus.loading;
      notifyListeners();

      final isIdUnique = await _service.isEmployeeIdUnique(
        employee.employeeId,
        excludeId: employee.id,
      );
      if (!isIdUnique) {
        _errorMessage = 'Employee ID "${employee.employeeId}" is already in use.';
        _status = EmployeeStatus.error;
        notifyListeners();
        return false;
      }

      final isEmailUnique = await _service.isEmailUnique(
        employee.email,
        excludeId: employee.id,
      );
      if (!isEmailUnique) {
        _errorMessage = 'Email "${employee.email}" is already registered.';
        _status = EmployeeStatus.error;
        notifyListeners();
        return false;
      }

      await _service.updateEmployee(employee);
      await _notifications.notifyEmployeeUpdated(employee.name);
      _status = EmployeeStatus.loaded;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update employee: $e';
      _status = EmployeeStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEmployee(Employee employee) async {
    try {
      await _service.deleteEmployee(employee.id);
      await _notifications.notifyEmployeeDeleted(employee.name);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete employee: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == EmployeeStatus.error) {
      _status = EmployeeStatus.loaded;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
