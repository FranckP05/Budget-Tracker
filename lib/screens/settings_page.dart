import 'package:flutter/material.dart';
import 'package:sudo_cash/screens/new_pwd_bottomSheet.dart';
import 'package:sudo_cash/screens/select_currency.dart';
import 'package:sudo_cash/screens/user_info_bottomSheet.dart';
import 'package:sudo_cash/screens/modify_pwd_bottomSheet.dart';
import 'package:sudo_cash/screens/delete_Password.dart';

class Settings extends StatelessWidget {
  final String username;
  final String password;
  final int userId;
  final VoidCallback onBack;

  const Settings({
    super.key,
    required this.username,
    required this.password,
    required this.userId,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Colors.black,
        foregroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
        elevation: 1,
        leading: BackButton(
          onPressed: () {
            onBack();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "GENERAL",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              /// Modify Account Info Button
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) {
                      return UserBottomSheet(
                        username: username,
                        password: password,
                        userId: userId,
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people, size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "Modify your account info",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              /// Set a New Password Button
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) {
                      return PasswordBottomSheet(
                        username: username,
                        password: password,
                        userId: userId,
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.add, size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "Set a new password",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              /// Modify Password Button
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) {
                      return ModifyBottomSheet(
                        username: username,
                        password: password,
                        userId: userId,
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit, size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "Modify the password",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              /// Delete Password Button
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        buildDeleteConfirmationDialog(context, userId),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.delete, size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "Delete the Password",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              /// Change Currency Button
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    isScrollControlled: true,
                    builder: (context) {
                      return const CurrencyBottomSheet();
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.currency_exchange, size: 24),
                          const SizedBox(width: 10),
                          const Text(
                            "Change the Currency",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "MANUAL",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),

              /// User Manual Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text("User Manual")],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}