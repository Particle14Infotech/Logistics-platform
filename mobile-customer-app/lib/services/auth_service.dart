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

  // Returns fresh tokens (backend now reissues them on every /auth/register
  // call, not just role changes) - needed because we no longer pre-set a
  // session before this call completes, see otp_login_screen.dart.
  Future<AuthResult> completeProfile({required String userId, required String name}) async {
    final response = await _dio.post('/auth/register', data: {'userId': userId, 'name': name});
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

  Future<void> registerFcmToken(String token) async {
    await _dio.post('/auth/fcm-token', data: {'token': token});
  }
}
