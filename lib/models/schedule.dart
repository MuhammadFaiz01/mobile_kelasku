class Schedule {
  final String id;
  final String mataKuliah;
  final String dosen;
  final String ruangan;
  final DateTime waktuMulai;
  final DateTime waktuSelesai;
  final ScheduleStatus status;
  final String kelas;
  final String semester;

  Schedule({
    required this.id,
    required this.mataKuliah,
    required this.dosen,
    required this.ruangan,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.status,
    required this.kelas,
    required this.semester,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      mataKuliah: json['mataKuliah'],
      dosen: json['dosen'],
      ruangan: json['ruangan'],
      waktuMulai: DateTime.parse(json['waktuMulai']),
      waktuSelesai: DateTime.parse(json['waktuSelesai']),
      status: ScheduleStatus.values.firstWhere(
        (e) => e.toString() == 'ScheduleStatus.${json['status']}',
      ),
      kelas: json['kelas'],
      semester: json['semester'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mataKuliah': mataKuliah,
      'dosen': dosen,
      'ruangan': ruangan,
      'waktuMulai': waktuMulai.toIso8601String(),
      'waktuSelesai': waktuSelesai.toIso8601String(),
      'status': status.toString().split('.').last,
      'kelas': kelas,
      'semester': semester,
    };
  }

  String get formattedTime {
    return '${waktuMulai.hour.toString().padLeft(2, '0')}:${waktuMulai.minute.toString().padLeft(2, '0')} - ${waktuSelesai.hour.toString().padLeft(2, '0')}:${waktuSelesai.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${waktuMulai.day} ${months[waktuMulai.month - 1]} ${waktuMulai.year}';
  }
}

enum ScheduleStatus {
  online,
  offline,
}