import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart'; // Adjust import path
import 'package:sudo_cash/screens/category_selection_page.dart'; // Adjust import path for CategorySelectionPage

class ShowWallets extends StatefulWidget {
  final Map<String, dynamic> expenseData; // Data from the bottom sheet

  const ShowWallets({required this.expenseData, Key? key}) : super(key: key);

  @override
  State<ShowWallets> createState() => _ShowWalletsState();
}

class _ShowWalletsState extends State<ShowWallets> {
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Map<String, dynamic>>> _walletsFuture;

  @override
  void initState() {
    super.initState();
    _walletsFuture = dbHelper.getAllWallets(); // Fetch wallets when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Wallet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text(
                "Choose a wallet for your expense",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _walletsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No wallets available'));
                }

                final wallets = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true, // Prevents unbounded height error in Column
                  physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
                  itemCount: wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = wallets[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(wallet['name_wallets']),
                        subtitle: Text('Total: ${wallet['total']}'),
                        trailing: Icon(
                          Icons.arrow_forward,
                          color: Color(int.parse(wallet['color'].replaceFirst('#', ''), radix: 16) | 0xFF000000),
                        ),
                        onTap: () {
                          // Navigate to CategorySelectionPage with wallet ID and expense data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategorySelectionPage(
                                walletId: wallet['walletID'],
                                expenseData: widget.expenseData,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}