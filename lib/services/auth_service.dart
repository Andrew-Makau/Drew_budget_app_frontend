import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AuthService = handles API calls to Flask backend for authentication
class AuthService {
  // secure storage (platform-safe)
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // choose baseUrl depending on platform: web vs emulator
  static String get _baseUrl {
    if (kIsWeb) {
      return "http://127.0.0.1:5000"; // web
    } else {
      return "http://10.0.2.2:5000"; // android emulator
      // if testing on a real device, replace with your machine IP e.g. http://192.168.x.y:5000
    }
  }

  // Dio client
  final Dio _dio;

  AuthService() : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json"},
  )) {
    // Add interceptor that reads token from secure storage for each request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // ignore storage read errors here (we'll handle on call)
        }
        return handler.next(options);
      },
    ));
  }

  /// SIGNUP method → creates new user (sends email + password)
  Future<Response> signup(String email, String password) async {
    try {
      final response = await _dio.post(
        "/signup",
        data: {"email": email, "password": password},
      );
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// LOGIN method → logs in existing user and saves token
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/login",
        data: {"email": email, "password": password},
      );

      // Try to extract token from common keys: access_token, token
      final data = response.data;
      final token = data != null
          ? (data['access_token'] ?? data['token'] ?? data['accessToken'])
          : null;

      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token.toString());
      }

      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Logout: delete token
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  /// Read token (useful in main.dart)
  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');

  /// A quick "is logged in" helper
  Future<bool> isLoggedIn() async => (await getToken()) != null;

  /// Error handler → makes errors beginner-friendly
  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;
      if (data is Map && data.isNotEmpty) {
        return (data['error'] ?? data['message'] ?? data.toString()).toString();
      } else {
        return data.toString();
      }
    } else {
      return e.message ?? "Network error";
    }
  }
}
