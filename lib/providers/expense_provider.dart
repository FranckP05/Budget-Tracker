import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart';
import 'package:sudo_cash/models/expense.dart';
import 'package:sudo_cash/constants.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  double _totalAmount = 0.0;
  double _limit = AppConstants.defaultExpenseLimit;
  bool _limitExceeded = false; // Track if the limit is exceeded

  List<Expense> get expenses => _expenses;
  double get totalAmount => _totalAmount;
  double get limit => _limit;
  bool get limitExceeded => _limitExceeded; // Expose limit exceeded status

  final DatabaseHelper _dbService = DatabaseHelper.instance;

  Future<void> fetchExpenses(int walletID, int categoryID) async {
    try {
      _expenses = await _dbService.getExpenses(walletID, categoryID);
      _totalAmount = _expenses.fold(0.0, (sum, exp) => sum + exp.amount);

      // Set the limit to the first expense's limit or the default limit
      _limit = _expenses.isNotEmpty ? _expenses.first.expenseLimit : AppConstants.defaultExpenseLimit;

      // Debugging: Print the total amount and limit
      print("Total Amount: $_totalAmount, Limit: $_limit");

      _checkLimit(); // Check if the limit has been exceeded
      notifyListeners();
    } catch (e) {
      print("Error fetching expenses: $e");
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _dbService.insertExpense(expense);
      await fetchExpenses(expense.walletID, expense.categoryID);
    } catch (e) {
      print("Error adding expense: $e");
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _dbService.updateExpense(expense);
      await fetchExpenses(expense.walletID, expense.categoryID);
    } catch (e) {
      print("Error updating expense: $e");
    }
  }

  Future<void> deleteExpense(int id, int walletID, int categoryID) async {
    try {
      await _dbService.deleteExpense(id);
      await fetchExpenses(walletID, categoryID);
    } catch (e) {
      print("Error deleting expense: $e");
    }
  }

  void _checkLimit() {
    bool newLimitExceeded = _totalAmount >= _limit;

    // Debugging: Print the limit exceeded status
    print("Limit Exceeded: $newLimitExceeded");

    if (newLimitExceeded != _limitExceeded) {
      _limitExceeded = newLimitExceeded;
      notifyListeners(); // Notify listeners only if the limit status changes
    }
  }
}