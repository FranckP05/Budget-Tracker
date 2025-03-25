import 'package:sudo_cash/constants.dart';

class Expense {
  final int? expenseID;
  final String name;
  final DateTime date;
  final String? description;
  final double amount;
  final int walletID;
  final int categoryID;
  final double expenseLimit;
  final String? icon;

  Expense({
    this.expenseID,
    required this.name,
    required this.date,
    this.description,
    required this.amount,
    required this.walletID,
    required this.categoryID,
    this.expenseLimit = AppConstants.defaultExpenseLimit,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'expenseID': expenseID,
      'name': name,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'walletID': walletID,
      'categoryID': categoryID,
      'expense_limit': expenseLimit,
      'icon': icon,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseID: map['expenseID'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      amount: map['amount'],
      walletID: map['walletID'],
      categoryID: map['categoryID'],
      expenseLimit: map['expense_limit'],
      icon: map['icon'],
    );
  }
}