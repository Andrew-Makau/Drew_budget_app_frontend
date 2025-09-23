import 'package:dio/dio.dart';

/// AuthService = handles API calls to Flask backend for authentication
class AuthService {
  /// Dio = HTTP client for Flutter (like axios in JavaScript)
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://127.0.0.1:5000", // Backend URL (for chrome) (for emulator use; baseUrl: "http://10.0.2.2:5000")
      connectTimeout: Duration(seconds: 5), // Wait max 5s before failing
      receiveTimeout: Duration(seconds: 5),
      headers: {
        "Content-Type": "application/json", // Sending data as JSON
      },
    ),
  );

  /// SIGNUP method → creates new user
  Future<Response> signup(String email, String password) async {
    try {
      final response = await _dio.post(
        "/signup", // Flask endpoint
        data: {
          "email": email,
          "password": password,
        },
      );
      return response; // If success, backend returns a JWT token
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// LOGIN method → logs in existing user
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/login", // Flask endpoint
        data: {
          "email": email,
          "password": password,
        },
      );
      return response;
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Error handler → makes errors beginner-friendly
  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      return e.response?.data["message"] ?? "Unknown error occurred";
    } else {
      return e.message ?? "Network error";
    }
  }
}
