import 'package:cloud_firestore/cloud_firestore.dart';

class Employee {
  final String id;
  final String name;
  final String employeeId;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final double salary;
  final DateTime joiningDate;
  final String address;
  final DateTime createdAt;

  Employee({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.salary,
    required this.joiningDate,
    required this.address,
    required this.createdAt,
  });

  factory Employee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Employee(
      id: doc.id,
      name: data['name'] ?? '',
      employeeId: data['employeeId'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      designation: data['designation'] ?? '',
      salary: (data['salary'] as num?)?.toDouble() ?? 0.0,
      joiningDate: (data['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      address: data['address'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'employeeId': employeeId,
      'email': email,
      'phone': phone,
      'department': department,
      'designation': designation,
      'salary': salary,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Employee copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? email,
    String? phone,
    String? department,
    String? designation,
    double? salary,
    DateTime? joiningDate,
    String? address,
    DateTime? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      salary: salary ?? this.salary,
      joiningDate: joiningDate ?? this.joiningDate,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
