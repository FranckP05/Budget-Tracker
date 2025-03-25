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
  _ExpensePresentationScreenState createState() =>
      _ExpensePresentationScreenState();
}

class _ExpensePresentationScreenState extends State<ExpensePresentationScreen>
    with TickerProviderStateMixin {
  DateTime? _filterDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses(
        widget.walletId,
        widget.categoryId); // Load data on screen open
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
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
        title: Text("Add an Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
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
                await Provider.of<ExpenseProvider>(context, listen: false)
                    .addExpense(
                  Expense(
                    name: name,
                    date: DateTime.now(),
                    description: desc,
                    amount: amount,
                    walletID: widget.walletId,
                    categoryID: widget.categoryId,
                    icon: widget.categoryName.toLowerCase(), // Use category name as icon key
                  ),
                );
                Navigator.pop(context); // Close dialog after adding
                setState(() {}); // Refresh screen if necessary
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Invalid input, please fill all fields correctly")),
                );
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // New gradient colors
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
    final amountController =
        TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
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
                await Provider.of<ExpenseProvider>(context, listen: false)
                    .updateExpense(
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
                Navigator.pop(context); // Close dialog after editing
              }
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // New gradient colors
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
        title: Text("${widget.categoryName} > Expenses", style: TextStyle(fontSize: 18),),
      ),
      body: Stack(
        children: [
          // Background image with animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
          ),
          // Main content
          Consumer<ExpenseProvider>(
            builder: (context, expenseProvider, child) {
              if (expenseProvider.totalAmount >= expenseProvider.limit) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
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
                  // Add button
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
                          gradient: LinearGradient(
                            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)], // New gradient colors
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
                  // Expense list
                  Expanded(
                    child: ExpenseListWidget(
                      expenses: filteredExpenses,
                      onEdit: _showEditExpenseDialog,
                      onDelete: (id) => expenseProvider.deleteExpense(
                          id, widget.walletId, widget.categoryId),
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