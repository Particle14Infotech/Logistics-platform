class UserModel {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String role;

  UserModel({required this.id, this.name, this.phone, this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'customer',
    );
  }
}
