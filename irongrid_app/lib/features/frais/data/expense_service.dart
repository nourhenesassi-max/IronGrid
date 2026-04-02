import 'dart:convert';
import 'dart:io';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import 'models/expense_dto.dart';

class ExpenseService {
  final _api = ApiClient();

  Future<void> createExpense({
    required String category,
    required double amount,
    required DateTime expenseDate,
    required String note,
    required File receiptFile,
    String currency = "TND",
  }) async {
    final res = await _api.multipartPost(
      "/api/expenses",
      fields: {
        "category": category,
        "amount": amount.toStringAsFixed(2),
        "currency": currency,
        "expenseDate":
            "${expenseDate.year}-${expenseDate.month.toString().padLeft(2, '0')}-${expenseDate.day.toString().padLeft(2, '0')}",
        "note": note,
      },
      file: receiptFile,
      fileFieldName: "receipt",
      withAuth: true,
    );

    final body = await res.stream.bytesToString();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("POST /api/expenses failed ${res.statusCode}: $body");
    }
  }

  Future<List<ExpenseDto>> myExpenses() async {
    final res = await _api.get("/api/expenses/me", withAuth: true);

    if (res.statusCode != 200) {
      throw Exception(
        "GET /api/expenses/me failed ${res.statusCode}: ${res.body}",
      );
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => ExpenseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  String? resolveReceiptUrl(String? receiptUrl) {
    if (receiptUrl == null || receiptUrl.isEmpty) return null;
    if (receiptUrl.startsWith("http")) return receiptUrl;
    return "${ApiConfig.baseUrl}$receiptUrl";
  }
}