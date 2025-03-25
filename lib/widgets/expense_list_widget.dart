// lib/widgets/expense_list_widget.dart
import 'package:flutter/material.dart';
import 'package:sudo_cash/models/expense.dart';
import 'package:sudo_cash/constants.dart';

class ExpenseListWidget extends StatefulWidget {
  final List<Expense> expenses;
  final Function(Expense) onEdit;
  final Function(int) onDelete;

  const ExpenseListWidget({
    Key? key,
    required this.expenses,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  _ExpenseListWidgetState createState() => _ExpenseListWidgetState();
}

class _ExpenseListWidgetState extends State<ExpenseListWidget> {
  final Map<int, bool> _expandedState = {}; // Tracks which cards are expanded

  // Dynamic icon mapping (expanded from category_page.dart)
  static const Map<String, IconData> expenseIcons = {
    'food': Icons.fastfood,
    'travel': Icons.flight,
    'shopping': Icons.shopping_cart,
    'entertainment': Icons.movie,
    'bills': Icons.receipt,
    'transport': Icons.directions_car,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'gifts': Icons.card_giftcard,
    'misc': Icons.category, // Default fallback
  };

  Icon _getIcon(String? iconKey) {
    final key = iconKey?.toLowerCase().trim() ?? 'misc';
    return Icon(
      expenseIcons[key] ?? expenseIcons['misc'],
      color: Colors.white,
      size: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.expenses.isEmpty
        ? Center(
            child: Text(
              "No expenses yet",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.builder(
            itemCount: widget.expenses.length,
            itemBuilder: (context, index) {
              final expense = widget.expenses[index];
              final isExpanded = _expandedState[index] ?? false;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedState[index] = !isExpanded; // Toggle expanded state
                  });
                },
                onLongPress: () => _showOptions(context, expense),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Card(
                    key: ValueKey(expense.expenseID),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppConstants.accentGradient, // Gradient background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getIcon(expense.icon),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  expense.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                "\$${expense.amount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${expense.date.day}/${expense.date.month}/${expense.date.year}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense.description ?? '',
                            maxLines: isExpanded ? null : 2, // Show 2 lines initially
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (isExpanded) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => widget.onEdit(expense),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => widget.onDelete(expense.expenseID!),
                                ),
                              ],
                            ),
                          ],
                        ],
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
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Edit"),
            onTap: () {
              Navigator.pop(context);
              widget.onEdit(expense);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete"),
            onTap: () {
              Navigator.pop(context);
              widget.onDelete(expense.expenseID!);
            },
          ),
        ],
      ),
    );
  }
}