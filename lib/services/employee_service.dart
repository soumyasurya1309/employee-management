import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  CollectionReference get _employeesRef =>
      _firestore.collection(_collection);

  Stream<List<Employee>> getEmployeesStream() {
    return _employeesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList());
  }

  Future<List<Employee>> getAllEmployees() async {
    final snapshot =
        await _employeesRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Employee.fromFirestore(doc)).toList();
  }

  Future<Employee?> getEmployeeById(String id) async {
    final doc = await _employeesRef.doc(id).get();
    if (doc.exists) return Employee.fromFirestore(doc);
    return null;
  }

  Future<String> addEmployee(Employee employee) async {
    final docRef = await _employeesRef.add(employee.toFirestore());
    return docRef.id;
  }

  Future<void> updateEmployee(Employee employee) async {
    await _employeesRef.doc(employee.id).update(employee.toFirestore());
  }

  Future<void> deleteEmployee(String id) async {
    await _employeesRef.doc(id).delete();
  }

  Future<bool> isEmployeeIdUnique(String employeeId, {String? excludeId}) async {
    Query query = _employeesRef.where('employeeId', isEqualTo: employeeId);
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return true;
    if (excludeId != null && snapshot.docs.length == 1 &&
        snapshot.docs.first.id == excludeId) {
      return true;
    }
    return false;
  }

  Future<bool> isEmailUnique(String email, {String? excludeId}) async {
    Query query = _employeesRef.where('email', isEqualTo: email.trim());
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) return true;
    if (excludeId != null && snapshot.docs.length == 1 &&
        snapshot.docs.first.id == excludeId) {
      return true;
    }
    return false;
  }
}
