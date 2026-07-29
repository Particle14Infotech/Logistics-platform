import 'package:firebase_auth/firebase_auth.dart' as fb;
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

  // --- Firebase email/password auth -------------------------------------
  // Firebase owns credential storage + email verification state; this
  // backend never sees the password. Once Firebase confirms the email is
  // verified, syncFirebaseSession() exchanges the Firebase ID token for this
  // app's own JWT session (same AuthResult shape as verifyOtp above), so
  // everything downstream of login is identical regardless of auth method.
  final _firebaseAuth = fb.FirebaseAuth.instance;

  Future<fb.User> registerWithEmail(String email, String password) async {
    final credential =
        await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user!.sendEmailVerification();
    return credential.user!;
  }

  Future<void> resendVerificationEmail() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  Future<fb.User> loginWithEmail(String email, String password) async {
    final credential =
        await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user!;
  }

  Future<AuthResult> syncFirebaseSession({String? role}) async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken(true);
    final response = await _dio.post('/auth/firebase-session', data: {
      'idToken': idToken,
      if (role != null) 'role': role,
    });
    final data = response.data['data'];
    return AuthResult(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: data['isNewUser'] as bool? ?? false,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Not signed in with an email/password account.');
    }
    final cred = fb.EmailAuthProvider.credential(email: user.email!, password: currentPassword);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }
}
