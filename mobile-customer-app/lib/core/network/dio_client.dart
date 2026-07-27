import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

// Single shared Dio instance so the refresh-token de-dupe logic below works
// across every screen, rather than each screen accidentally racing its own
// refresh call.
class DioClient {
  static const _storage = FlutterSecureStorage();
  static Dio? _instance;
  static Future<Response>? _refreshFuture;

  static Dio get instance => _instance ??= _build();

  static Dio _build() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl, connectTimeout: const Duration(seconds: 15)));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isAuthRoute = error.requestOptions.path.contains('/auth/');
          final alreadyRetried = error.requestOptions.extra['retried'] == true;

          if (error.response?.statusCode != 401 || isAuthRoute || alreadyRetried) {
            return handler.next(error);
          }

          final refreshToken = await _storage.read(key: 'refreshToken');
          if (refreshToken == null) {
            await _storage.deleteAll();
            return handler.next(error);
          }

          try {
            // De-dupe concurrent 401s into a single refresh call
            _refreshFuture ??= Dio(BaseOptions(baseUrl: ApiConstants.baseUrl))
                .post('/auth/refresh-token', data: {'refreshToken': refreshToken});
            final refreshResponse = await _refreshFuture!;
            _refreshFuture = null;

            final newAccessToken = refreshResponse.data['data']['accessToken'] as String;
            await _storage.write(key: 'accessToken', value: newAccessToken);

            final retryOptions = error.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            retryOptions.extra['retried'] = true;

            final retryResponse = await Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)).fetch(retryOptions);
            return handler.resolve(retryResponse);
          } catch (_) {
            _refreshFuture = null;
            await _storage.deleteAll();
            return handler.next(error);
          }
        },
      ),
    );

    return dio;
  }
}
