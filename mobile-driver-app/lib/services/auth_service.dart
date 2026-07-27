import '../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final bool isNewUser;

  AuthResult({required this.accessToken, required this.refreshToken, required this.user, required this.isNewUser});
}

class AuthService {
  final _dio = DioClient.instance;

  Future<void> sendOtp(String phone) async {
    await _dio.post('/auth/send-otp', data: {'phone': phone});
  }

  Future<AuthResult> verifyOtp(String phone, String otp) async {
    final response = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
    final data = response.data['data'];
    return AuthResult(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: data['isNewUser'] as bool? ?? false,
    );
  }

  // role: 'driver' or 'fleet_owner', set by RoleSelectionScreen via
  // selectedRoleProvider - distinguishes from the customer app's
  // completeProfile, which leaves role at its 'customer' default. Returns
  // fresh tokens: the backend now reissues them here since this is what
  // actually promotes a brand-new signup from the OTP-verify default of
  // 'customer' to the selected role - reusing the original OTP-verify
  // token would keep authorizing against the stale pre-registration role
  // until it expired.
  Future<AuthResult> completeProfile({required String userId, required String name, required String role}) async {
    final response = await _dio.post('/auth/register', data: {'userId': userId, 'name': name, 'role': role});
    final data = response.data['data'];
    return AuthResult(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: false,
    );
  }

  Future<UserModel> updateProfile({String? name, String? email}) async {
    final response = await _dio.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    });
    return UserModel.fromJson(response.data['data']['user'] as Map<String, dynamic>);
  }
}
