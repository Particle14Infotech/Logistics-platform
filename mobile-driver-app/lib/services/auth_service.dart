import 'dart:async';
import 'package:dio/dio.dart';
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

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? dob,
    bool? notificationsEnabled,
  }) async {
    final response = await _dio.put('/auth/profile', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (dob != null) 'dob': dob,
      if (notificationsEnabled != null) 'notificationsEnabled': notificationsEnabled,
    });
    return UserModel.fromJson(response.data['data']['user'] as Map<String, dynamic>);
  }

  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/profile');
    return UserModel.fromJson(response.data['data']['user'] as Map<String, dynamic>);
  }

  Future<void> registerFcmToken(String token) async {
    await _dio.post('/auth/fcm-token', data: {'token': token});
  }

  // --- Firebase email/password auth -------------------------------------
  // Firebase owns credential storage + email verification state; this
  // backend never sees the password. Once Firebase confirms the email is
  // verified, syncFirebaseSession() exchanges the Firebase ID token for this
  // app's own JWT session.
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

  // Alternative to the emailed link - X-Firebase-Token (not Authorization,
  // so it can never collide with DioClient's own Bearer-JWT interceptor,
  // which isn't relevant yet at this point - there's no app session, only
  // a Firebase one).
  Future<void> sendEmailVerificationOtp() async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken();
    await _dio.post('/auth/send-email-otp', options: Options(headers: {'X-Firebase-Token': idToken}));
  }

  Future<bool> verifyEmailOtp(String code) async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken();
    try {
      await _dio.post(
        '/auth/verify-email-otp',
        data: {'otp': code},
        options: Options(headers: {'X-Firebase-Token': idToken}),
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) return false;
      rethrow;
    }
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

  // role: 'driver' or 'fleet_owner', set by RoleSelectionScreen via
  // selectedRoleProvider - only used when this creates a brand-new local user.
  Future<AuthResult> syncFirebaseSession({String? role}) async {
    final idToken = await _firebaseAuth.currentUser!.getIdToken(true);
    final response = await _dio.post('/auth/firebase-session', data: {
      'idToken': idToken,
      'appContext': 'driver',
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

  // --- Firebase phone/SMS auth --------------------------------------------
  // A second, independent sign-in method alongside email/password (not a
  // replacement) - Firebase sends and verifies the SMS code itself via the
  // native SDK (Play Integrity on Android, no separate SMS gateway/API key
  // needed on our end). syncFirebaseSession() above is the same call the
  // email flow ends with; the backend's /auth/firebase-session endpoint
  // branches on whether the verified token carries a phone number or an
  // email, so this reuses that whole path rather than needing its own.

  // verifyPhoneNumber is callback-based, not Future-based - this adapts it
  // to the same "await, then react" shape as the rest of this class.
  // verificationCompleted (Android-only instant auto-verification, no code
  // typed at all) is deliberately unhandled: signing in immediately from
  // inside this callback would race the caller, which is still awaiting
  // this method for a verificationId to show the OTP field with. The OTP
  // screen covers that case anyway - autofill still fills the code in for
  // the user to submit normally.
  Future<String> sendPhoneOtp(String phoneNumber) async {
    final completer = Completer<String>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {},
      verificationFailed: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (verificationId, resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
    );
    return completer.future;
  }

  Future<fb.User> verifyPhoneOtp(String verificationId, String smsCode) async {
    final credential = fb.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    final result = await _firebaseAuth.signInWithCredential(credential);
    return result.user!;
  }
}
