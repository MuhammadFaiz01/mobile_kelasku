class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String nim; // untuk mahasiswa
  final String nip; // untuk dosen

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim = '',
    this.nip = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      nim: json['nim'] ?? '',
      nip: json['nip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'nim': nim,
      'nip': nip,
    };
  }
}

enum UserRole {
  mahasiswa,
  dosen,
}