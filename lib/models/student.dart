import '../../models/attendance.dart'; // enum AttendanceStatus

class Student {
  final String id;
  final String name;
  final String studentId;     // mis. NIM
  final String photoUrl;
  final AttendanceStatus status;

  const Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.photoUrl,
    required this.status,
  });

  /// clone dengan perubahan sebagian field
  Student copyWith({
    String? id,
    String? name,
    String? studentId,
    String? photoUrl,
    AttendanceStatus? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studentId: studentId ?? this.studentId,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
    );
  }

  /// (opsional) serialisasi
  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        studentId: json['studentId'],
        photoUrl: json['photoUrl'],
        status: AttendanceStatus.values.firstWhere(
          (e) => e.toString() == 'AttendanceStatus.${json['status']}',
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'studentId': studentId,
        'photoUrl': photoUrl,
        'status': status.toString().split('.').last,
      };
}
