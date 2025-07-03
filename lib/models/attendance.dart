class Attendance {
  final String id;
  final String scheduleId;
  final String studentId;
  final DateTime timestamp;
  final AttendanceStatus status;
  final AttendanceMethod method;
  final String? notes;

  Attendance({
    required this.id,
    required this.scheduleId,
    required this.studentId,
    required this.timestamp,
    required this.status,
    required this.method,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      scheduleId: json['scheduleId'],
      studentId: json['studentId'],
      timestamp: DateTime.parse(json['timestamp']),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${json['status']}',
      ),
      method: AttendanceMethod.values.firstWhere(
        (e) => e.toString() == 'AttendanceMethod.${json['method']}',
      ),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'studentId': studentId,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'notes': notes,
    };
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}';
  }
}

enum AttendanceStatus {
  hadir,
  terlambat,
  tidak_hadir,
  sakit,
  izin,
}

enum AttendanceMethod {
  qr_code,
  face_recognition,
}