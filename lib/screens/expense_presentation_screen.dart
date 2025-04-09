import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_list_widget.dart';

class ExpensePresentationScreen extends StatefulWidget {
  final String walletName;
  final String categoryName;
  final int walletId;
  final int categoryId;

  const ExpensePresentationScreen({
    required this.walletName,
    required this.categoryName,
    required this.walletId,
    required this.categoryId,
  });

  @override
  _ExpensePresentationScreenState createState() => _ExpensePresentationScreenState();
}

class _ExpensePresentationScreenState extends State<ExpensePresentationScreen> with TickerProviderStateMixin {
  DateTime? _filterDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses(widget.walletId, widget.categoryId);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add an Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (name.isNotEmpty && amount > 0) {
                await Provider.of<ExpenseProvider>(context, listen: false).addExpense(
                  Expense(
                    name: name,
                    date: DateTime.now(),
                    description: desc,
                    amount: amount,
                    walletID: widget.walletId,
                    categoryID: widget.categoryId,
                    icon: widget.categoryName.toLowerCase(),
                  ),
                );
                Navigator.pop(context, true); // Return true on success
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Invalid input, please fill all fields correctly")),
                );
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                alignment: Alignment.center,
                child: const Text(
                  "Add",
                  style: TextStyle(
                    color: AppConstants.backgroundWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditExpenseDialog(Expense expense) {
    final nameController = TextEditingController(text: expense.name);
    final descController = TextEditingController(text: expense.description);
    final amountController = TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (name.isNotEmpty && amount > 0) {
                await Provider.of<ExpenseProvider>(context, listen: false).updateExpense(
                  Expense(
                    expenseID: expense.expenseID,
                    name: name,
                    date: expense.date,
                    description: desc,
                    amount: amount,
                    walletID: widget.walletId,
                    categoryID: widget.categoryId,
                    expenseLimit: expense.expenseLimit,
                    icon: expense.icon,
                  ),
                );
                Navigator.pop(context, true); // Return true on success
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50.0),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                alignment: Alignment.center,
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: AppConstants.backgroundWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        elevation: 1,
        title: Text("${widget.categoryName} -> Expenses", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black26,
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
          ),
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              if (expenseProvider.totalAmount >= expenseProvider.limit) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Expense limit reached!"),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }

              final filteredExpenses = _filterDate == null
                  ? expenseProvider.expenses
                  : expenseProvider.expenses
                      .where((exp) =>
                          exp.date.day == _filterDate!.day &&
                          exp.date.month == _filterDate!.month &&
                          exp.date.year == _filterDate!.year)
                      .toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                      ),
                      onPressed: _showAddExpenseDialog,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          alignment: Alignment.center,
                          child: const Text(
                            "Add an Expense",
                            style: TextStyle(
                              color: AppConstants.backgroundWhite,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ExpenseListWidget(
                      expenses: filteredExpenses,
                      onEdit: _showEditExpenseDialog,
                      onDelete: (id) async {
                        await expenseProvider.deleteExpense(id, widget.walletId, widget.categoryId);
                        Navigator.pop(context, true); // Return true on delete
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}