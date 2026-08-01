import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../services/socket_service.dart';

class AuthState {
  final String? accessToken;
  final String? refreshToken;
  final UserModel? user;
  final bool isLoading;

  const AuthState({this.accessToken, this.refreshToken, this.user, this.isLoading = true});

  bool get isAuthenticated => accessToken != null && user != null;

  AuthState copyWith({String? accessToken, String? refreshToken, UserModel? user, bool? isLoading}) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  static const _storage = FlutterSecureStorage();

  Future<void> _restoreSession() async {
    final accessToken = await _storage.read(key: 'accessToken');
    final refreshToken = await _storage.read(key: 'refreshToken');
    final userId = await _storage.read(key: 'userId');
    final userName = await _storage.read(key: 'userName');
    final userPhone = await _storage.read(key: 'userPhone');
    // Falls back to 'driver' only for sessions stored before this field
    // existed - previously this was ALWAYS hard-coded to 'driver' on
    // restore, silently reassigning every restored fleet_owner back to
    // 'driver' on every app restart. That sent them down the router's
    // driver branch instead of the fleet branch, which 403s fetching
    // /driver/profile (authorize('driver')-gated) and got treated as a
    // permanent "this account isn't registered as a driver" lockout with
    // no way back in except signing out and re-registering.
    final userRole = await _storage.read(key: 'userRole');

    if (accessToken != null && userId != null) {
      state = AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: UserModel(id: userId, name: userName, phone: userPhone, role: userRole ?? 'driver'),
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setSession({required String accessToken, required String refreshToken, required UserModel user}) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    await _storage.write(key: 'userId', value: user.id);
    await _storage.write(key: 'userRole', value: user.role);
    if (user.name != null) await _storage.write(key: 'userName', value: user.name);
    if (user.phone != null) await _storage.write(key: 'userPhone', value: user.phone);

    state = AuthState(accessToken: accessToken, refreshToken: refreshToken, user: user, isLoading: false);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    state = state.copyWith(accessToken: accessToken);
  }

  Future<void> logout() async {
    SocketService().dispose();
    await _storage.deleteAll();
    // Backend session and Firebase session are two independent systems
    // (see auth_service.dart) - clearing only secure storage left
    // FirebaseAuth.instance.currentUser pointing at whoever last signed in
    // via email/password on this device. On a shared device, a second
    // person logging in via phone OTP (which never touches Firebase)
    // would then have changePassword()/checkEmailVerified() etc. silently
    // operate against the FIRST person's still-signed-in Firebase account.
    try {
      await fb.FirebaseAuth.instance.signOut();
    } catch (_) {
      // No Firebase session to sign out of (e.g. this device only ever
      // used phone OTP) - nothing to do.
    }
    state = const AuthState(isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
