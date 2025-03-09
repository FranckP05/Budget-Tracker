import '../constants.dart';

class Expense {
  final int? id;
  final String name;
  final DateTime date;
  final String description;
  final double amount;
  final int walletId;
  final int categoryId;
  final double limit;
  final String? icon;

  Expense({
    this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.amount,
    required this.walletId,
    required this.categoryId,
    this.limit = AppConstants.defaultExpenseLimit,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'walletId': walletId,
      'categoryId': categoryId,
      'limit': limit,
      'icon': icon,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      amount: map['amount'],
      walletId: map['walletId'],
      categoryId: map['categoryId'],
      limit: map['limit'] ?? AppConstants.defaultExpenseLimit,
      icon: map['icon'],
    );
  }
}
