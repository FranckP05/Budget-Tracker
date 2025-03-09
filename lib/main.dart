import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'screens/expense_presentation_screen.dart';
import 'providers/expense_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
          scaffoldBackgroundColor: AppConstants.backgroundWhite,
          textTheme: TextTheme(
            bodyMedium: TextStyle(color: AppConstants.textBlack),
          ),
        ),
        home: ExpensePresentationScreen(
          walletName: "Wallet1",
          categoryName: "Transport",
          walletId: 1,
          categoryId: 1,
        ),
      ),
    );
  }
}
