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
    with SingleTickerProviderStateMixin {
  DateTime? _filterDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses(
        widget.walletId,
        widget.categoryId); // Charger les données à l'ouverture
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

  // j'afficher le formulaire d'ajout
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
              backgroundColor: AppConstants.accentPurple,
              foregroundColor: AppConstants.backgroundWhite,
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
                    walletId: widget.walletId,
                    categoryId: widget.categoryId,
                    icon: widget.categoryName == "Transport"
                        ? "bus_icon"
                        : "food_icon",
                  ),
                );
                Navigator.pop(context); // Je ferme le dialogue après ajout
                setState(() {}); // Je rafraîchir l’écran si nécessaire
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          "Invalid input, please fill all fields correctly")),
                );
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  // j'afficher le formulaire de modification
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
              backgroundColor: AppConstants.accentPurple,
              foregroundColor: AppConstants.backgroundWhite,
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (name.isNotEmpty && amount > 0) {
                await Provider.of<ExpenseProvider>(context, listen: false)
                    .updateExpense(
                  Expense(
                    id: expense.id,
                    name: name,
                    date: expense.date,
                    description: desc,
                    amount: amount,
                    walletId: widget.walletId,
                    categoryId: widget.categoryId,
                    limit: expense.limit,
                    icon: expense.icon,
                  ),
                );
                Navigator.pop(context); // Ferme le dialogue après modification
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond avec animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
          ),
          // Contenu principal
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
                  // mon header personnalisé
                  Container(
                    color: AppConstants.primaryGreen.withOpacity(0.9),
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top, bottom: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: AppConstants.backgroundWhite),
                          onPressed: () {
                            Navigator.pop(
                                context); // Retourne à l’écran précédent
                          },
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            widget.walletName,
                            style:
                                TextStyle(color: AppConstants.backgroundWhite),
                          ),
                        ),
                        Icon(Icons.arrow_back,
                            color: AppConstants.backgroundWhite),
                        Text(
                          widget.categoryName,
                          style: TextStyle(color: AppConstants.backgroundWhite),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.filter_list,
                              color: AppConstants.backgroundWhite),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => _filterDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Bouton d'ajout
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentPurple,
                        foregroundColor: AppConstants.backgroundWhite,
                      ),
                      onPressed: _showAddExpenseDialog,
                      child: Text("Add an Expense"),
                    ),
                  ),
                  // Liste des dépenses
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
