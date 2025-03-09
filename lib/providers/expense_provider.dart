import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../constants.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  double _totalAmount = 0.0;
  double _limit = AppConstants.defaultExpenseLimit;

  List<Expense> get expenses => _expenses;
  double get totalAmount => _totalAmount;
  double get limit => _limit;

  final DatabaseService _dbService = DatabaseService();
  bool _defaultExpensesAdded =
      false; // Indicateur pour éviter d'ajouter plusieurs fois

  // Je charger les dépenses depuis la DB
  Future<void> fetchExpenses(int walletId, int categoryId) async {
    _expenses = await _dbService.getExpenses(walletId, categoryId);

    // J'ajouter des dépenses par défaut uniquement si elles n'ont pas encore été ajoutées
    if (_expenses.isEmpty && !_defaultExpensesAdded) {
      await _dbService.insertExpense(Expense(
        name: "Bus Ticket",
        date: DateTime.now().subtract(Duration(days: 1)),
        description: "Daily commute",
        amount: 2.50,
        walletId: walletId,
        categoryId: categoryId,
        icon: "bus_icon",
      ));
      await _dbService.insertExpense(Expense(
        name: "Lunch",
        date: DateTime.now(),
        description: "Restaurant meal",
        amount: 15.00,
        walletId: walletId,
        categoryId: categoryId,
        icon: "food_icon",
      ));
      _defaultExpensesAdded = true; // Marquer comme ajouté
      _expenses =
          await _dbService.getExpenses(walletId, categoryId); // Rafraîchir
    }

    _totalAmount = _expenses.fold(0.0, (sum, exp) => sum + exp.amount);
    _limit = _expenses.isNotEmpty
        ? _expenses.first.limit
        : AppConstants.defaultExpenseLimit;
    notifyListeners();
  }

  // J'ajouter une dépense
  Future<void> addExpense(Expense expense) async {
    await _dbService.insertExpense(expense);
    await fetchExpenses(
        expense.walletId, expense.categoryId); // Je rafraîchir après ajout
    _checkLimit();
  }

  // Je Met à jour une dépense
  Future<void> updateExpense(Expense expense) async {
    await _dbService.updateExpense(expense);
    await fetchExpenses(expense.walletId, expense.categoryId);
    _checkLimit();
  }

  // Je supprime une dépense
  Future<void> deleteExpense(int id, int walletId, int categoryId) async {
    await _dbService.deleteExpense(id);
    await fetchExpenses(walletId, categoryId);
    _checkLimit();
  }

  //Je  Vérifie si la limite est atteinte
  void _checkLimit() {
    if (_totalAmount >= _limit) {
      notifyListeners();
    }
  }
}
