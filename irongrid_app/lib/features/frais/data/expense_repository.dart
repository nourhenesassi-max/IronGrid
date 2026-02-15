import 'models/expense_model.dart';

class ExpenseRepository {
  static final ExpenseRepository _instance = ExpenseRepository._internal();
  factory ExpenseRepository() => _instance;
  ExpenseRepository._internal();

  final List<Expense> _expenses = [];

  List<Expense> getAll() => List.unmodifiable(_expenses);

  void add(Expense expense) {
    _expenses.insert(0, expense); // newest first
  }

  void clear() {
    _expenses.clear();
  }
}
