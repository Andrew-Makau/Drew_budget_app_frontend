// lib/services/transaction_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Determine base URL by platform
  static String get _baseUrl {
    if (kIsWeb) return "http://127.0.0.1:5000"; // Flutter web
    return "http://10.0.2.2:5000";               // Android emulator
    // If running on a real device, replace with your PC IP: http://192.168.x.y:5000
  }

  final Dio _dio;

  TransactionService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {"Content-Type": "application/json"},
        ));

  /// Fetch transactions for the logged-in user.
  /// If [token] is omitted, the service will try to read token from secure storage
  Future<List<dynamic>> fetchTransactions({String? token}) async {
    try {
      // If token not passed, read it from secure storage
      final t = token ?? await _storage.read(key: 'jwt_token');
      if (t == null) throw Exception('No JWT token found. Please login.');

      final resp = await _dio.get(
        "/transactions",
        options: Options(
          headers: {"Authorization": "Bearer $t"},
        ),
      );

      // Expect backend to return { "transactions": [...] }
      final data = resp.data;
      if (data is Map && data['transactions'] != null) {
        return List<dynamic>.from(data['transactions']);
      }

      // If backend returned a raw list fallback (less likely because we updated backend)
      if (data is List) return List<dynamic>.from(data);

      throw Exception('Unexpected response format from server.');
    } on DioException catch (e) {
      // Try to show friendly error message
      final msg = (e.response?.data != null && e.response?.data is Map)
          ? (e.response!.data['error'] ?? e.response!.data['message'] ?? e.toString())
          : e.message;
      throw Exception(msg);
    }
  }
}
