import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart'; // Adjust the import path
import 'package:sudo_cash/models/expense.dart'; // Adjust the import path

class CategorySelectionPage extends StatefulWidget {
  final int walletId;
  final Map<String, dynamic> expenseData;

  const CategorySelectionPage({required this.walletId, required this.expenseData, super.key});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DatabaseHelper.instance.getCategoriesByWallet(widget.walletId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Category'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories found for this wallet'));
          }

          final categories = snapshot.data!;
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category['name']),
                trailing: Icon(Icons.arrow_forward, color: Color(int.parse(category['color'].replaceFirst('#', ''), radix: 16) | 0xFF000000)),
                onTap: () async {
                  // Finalize the expense with walletId and categoryId
                  final expense = Expense(
                    name: widget.expenseData['name'],
                    description: widget.expenseData['description'],
                    amount: widget.expenseData['amount'],
                    date: widget.expenseData['date'],
                    walletID: widget.walletId,
                    categoryID: category['categoryID'],
                    expenseLimit: widget.expenseData['expense_limit'] ?? 100.0,
                    icon: widget.expenseData['icon'],
                  );

                  // Insert the expense into the database
                  await DatabaseHelper.instance.insertExpense(expense);

                  // Pop back to the previous screen (or wherever you want)
                  Navigator.popUntil(context, (route) => route.isFirst);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Expense added successfully!')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}