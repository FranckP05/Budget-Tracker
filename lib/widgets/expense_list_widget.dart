// lib/widgets/expense_list_widget.dart
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/expense.dart';

class ExpenseListWidget extends StatelessWidget {
  final List<Expense> expenses;
  final Function(Expense) onEdit;
  final Function(int) onDelete;

  const ExpenseListWidget({
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _getIcon(String? icon) {
    switch (icon) {
      case "bus_icon":
        return Icon(Icons.directions_bus, color: AppConstants.accentPurple);
      case "food_icon":
        return Icon(Icons.restaurant, color: AppConstants.accentPurple);
      default:
        return Icon(Icons.attach_money, color: AppConstants.accentPurple);
    }
  }

  @override
  Widget build(BuildContext context) {
    return expenses.isEmpty
        ? Center(
            child: Text(
              "No expenses yet",
              style: TextStyle(color: AppConstants.textBlack, fontSize: 18),
            ),
          )
        : ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return GestureDetector(
                onLongPress: () => _showOptions(context, expense),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: Card(
                    key: ValueKey(expense.id),
                    color: AppConstants.backgroundWhite.withOpacity(0.9),
                    elevation: 2,
                    child: ListTile(
                      leading: _getIcon(expense.icon),
                      title: Text(
                        expense.name,
                        style: TextStyle(color: AppConstants.textBlack),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            expense.description,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: Text(
                        "\$${expense.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: AppConstants.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }

  void _showOptions(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              onEdit(expense);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delete"),
            onTap: () {
              Navigator.pop(context);
              onDelete(expense.id!);
            },
          ),
        ],
      ),
    );
  }
}
