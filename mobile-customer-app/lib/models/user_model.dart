class UserModel {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? dob;
  final String role;
  final bool notificationsEnabled;

  UserModel({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.dob,
    required this.role,
    this.notificationsEnabled = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dob: json['dob'] as String?,
      role: json['role'] as String? ?? 'customer',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    );
  }
}
