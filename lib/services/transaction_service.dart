import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://10.0.2.2:5000", // use for Android emulator; Chrome => 127.0.0.1
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {"Content-Type": "application/json"},
    ),
  );

  /// Fetch all transactions for the current logged-in user
  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); // ✅ token saved from login

      if (token == null) {
        throw Exception("User not logged in — missing token");
      }

      final response = await _dio.get(
        "/transactions",
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        // Convert backend response to List<Map<String, dynamic>>
        List data = response.data;
        return data.map<Map<String, dynamic>>((t) {
          return {
            "id": t["id"],
            "title": t["note"] ?? "No title",
            "category": "General", // backend may not send category name directly
            "amount": t["amount"]?.toDouble() ?? 0.0,
            "type": t["type"],
            "date": DateTime.tryParse(t["date"] ?? ""),
            "categoryColor": t["type"] == "income"
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE57373),
          };
        }).toList();
      } else {
        throw Exception("Failed to load transactions: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["error"] ?? "Network or server error");
    }
  }
}
