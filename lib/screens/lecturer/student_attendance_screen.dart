import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/student.dart';
import '../../models/attendance.dart';
import '../../providers/student_attendance_provider.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Mahasiswa'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<StudentAttendanceProvider>().submitAttendance(),
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.send),
        label: const Text('Kirim'),
      ),
      body: Consumer<StudentAttendanceProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(
              child: Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => provider.submitAttendance(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: provider.students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _StudentTile(student: provider.students[i]),
            ),
          );
        },
      ),
    );
  }
}

/*───────────────────────────────────────────────────────────────────────────────*/
/*                              MODERN ITEM TILE                                */
/*───────────────────────────────────────────────────────────────────────────────*/

class _StudentTile extends StatelessWidget {
  const _StudentTile({required this.student});

  final Student student;

  static const _labels = <AttendanceStatus, (String, IconData)>{
    AttendanceStatus.hadir: ('Hadir', Icons.check_circle),
    AttendanceStatus.terlambat: ('Terlambat', Icons.schedule),
    AttendanceStatus.sakit: ('Sakit', Icons.sick),
    AttendanceStatus.izin: ('Izin', Icons.assignment_turned_in),
    AttendanceStatus.tidak_hadir: ('Alfa', Icons.cancel),
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.read<StudentAttendanceProvider>();
    final (label, icon) = _labels[student.status]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* FOTO MAHASISWA */
          CircleAvatar(
            backgroundImage: NetworkImage(student.photoUrl),
            radius: 28,
          ),
          const SizedBox(width: 14),

          /* DETAIL MAHASISWA */
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 4),
              Text('NIM: ${student.studentId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),

              /* CHIP STATUS */
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(student.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Icon(icon, color: _statusColor(student.status), size: 16),
                      const SizedBox(width: 6),
                      Text(label, style: TextStyle(color: _statusColor(student.status), fontSize: 12, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /* SEGMENTED BUTTON MODERN */
              SegmentedButton<AttendanceStatus>(
                showSelectedIcon: false,
                selected: {student.status},
                segments: _labels.entries.map(
                  (e) => ButtonSegment<AttendanceStatus>(
                    value: e.key,
                    icon: Icon(e.value.$2, size: 18),
                    label: Text(e.value.$1, style: const TextStyle(fontSize: 11)),
                  ),
                ).toList(),
                style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 4)),
                  visualDensity: VisualDensity.compact,
                ),
                onSelectionChanged: (set) => provider.updateStatus(student.id, set.first),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  /* Warna Status Modern */
  Color _statusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.hadir:
        return Colors.green;
      case AttendanceStatus.terlambat:
        return Colors.orange;
      case AttendanceStatus.sakit:
        return Colors.teal;
      case AttendanceStatus.izin:
        return Colors.blueGrey;
      case AttendanceStatus.tidak_hadir:
        return Colors.red;
    }
  }
}
