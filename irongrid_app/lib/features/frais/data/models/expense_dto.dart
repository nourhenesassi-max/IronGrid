class ExpenseDto {
  final int id;
  final String category;
  final double amount;
  final String currency;
  final DateTime expenseDate;
  final String note;
  final String status;
  final String? receiptUrl;
  final String? reviewReason;
  final String? employeeName;
  final String? employeeEmail;
  final DateTime? createdAt;

  ExpenseDto({
    required this.id,
    required this.category,
    required this.amount,
    required this.currency,
    required this.expenseDate,
    required this.note,
    required this.status,
    required this.receiptUrl,
    required this.reviewReason,
    required this.employeeName,
    required this.employeeEmail,
    required this.createdAt,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> j) {
    final rawAmount = j["amount"];

    return ExpenseDto(
      id: (j["id"] is num) ? (j["id"] as num).toInt() : 0,
      category: (j["category"] ?? "") as String,
      amount: (rawAmount is num)
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount?.toString() ?? "0") ?? 0.0,
      currency: (j["currency"] ?? "TND") as String,
      expenseDate: DateTime.tryParse((j["expenseDate"] ?? "").toString()) ??
          DateTime.now(),
      note: (j["note"] ?? "") as String,
      status: (j["status"] ?? "PENDING") as String,
      receiptUrl: j["receiptUrl"]?.toString(),
      reviewReason: j["reviewReason"]?.toString(),
      employeeName: j["employeeName"]?.toString(),
      employeeEmail: j["employeeEmail"]?.toString(),
      createdAt: j["createdAt"] != null
          ? DateTime.tryParse(j["createdAt"].toString())
          : null,
    );
  }
}