class UserDto {
  final String userId;
  final String nama;
  final String email;
  final String role; // 'Kasir' atau 'Pemilik'
  final String? token;

  UserDto({
    required this.userId,
    required this.nama,
    required this.email,
    required this.role,
    this.token,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['user_id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Kasir',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'nama': nama,
    'email': email,
    'role': role,
  };
}
