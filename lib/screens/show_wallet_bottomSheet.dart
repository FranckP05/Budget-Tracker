import 'package:flutter/material.dart';
import 'choose_wallet.dart';

class ShowWalletBottomSheet extends StatefulWidget {
  const ShowWalletBottomSheet({Key? key}) : super(key: key);

  @override
  State<ShowWalletBottomSheet> createState() => _ShowWalletBottomSheetState();
}

final titleController = TextEditingController();
final descriptionController = TextEditingController();
final amountController = TextEditingController();
final _formKey = GlobalKey<FormState>();

class _ShowWalletBottomSheetState extends State<ShowWalletBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              "Add an expense",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 14)),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 20, right: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    hintText: "Title of your expense",
                    labelText: "Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for your expense';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 20, right: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    hintText: "Describe your expense",
                    labelText: "Description",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe your expense';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 20, right: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    hintText: "amount of your expense",
                    labelText: "Amount",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ), // Adjusted padding
                        backgroundColor: const Color(0xff9c1c0b),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        titleController.text = '';
                        descriptionController.text = '';
                        amountController.text = '';
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ), // Adjusted padding
                        backgroundColor: const Color(0xff109710),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final expenseData = {
                            'name': titleController.text,
                            'description': descriptionController.text,
                            'amount': double.parse(amountController.text),
                            'date': DateTime.now(),
                          };
                          Navigator.pop(context); // Close bottom sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ShowWallets(expenseData: expenseData),
                            ),
                          );
                        }
                      },
                      child: const Text('add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 20)),
        ],
      ),
    );
  }
}
