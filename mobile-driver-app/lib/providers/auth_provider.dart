import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

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

    if (accessToken != null && userId != null) {
      state = AuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: UserModel(id: userId, name: userName, phone: userPhone, role: 'driver'),
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
    if (user.name != null) await _storage.write(key: 'userName', value: user.name);
    if (user.phone != null) await _storage.write(key: 'userPhone', value: user.phone);

    state = AuthState(accessToken: accessToken, refreshToken: refreshToken, user: user, isLoading: false);
  }

  Future<void> updateAccessToken(String accessToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    state = state.copyWith(accessToken: accessToken);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState(isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
