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

  void _showBottomSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      isScrollControlled: true, // This allows full-screen height adjustments
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context)
              .viewInsets, // Moves sheet up on keyboard open
          child: child,
        );
      },
    );
  }

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
                onTap: () => _showBottomSheet(
                  context,
                  UserBottomSheet(
                      username: username, password: password, userId: userId),
                ),
                child: _buildSettingsItem(
                    Icons.people, "Modify your account info"),
              ),

              /// Set a New Password Button
              InkWell(
                onTap: () => _showBottomSheet(
                  context,
                  PasswordBottomSheet(
                      username: username, password: password, userId: userId),
                ),
                child: _buildSettingsItem(Icons.add, "Set a new password"),
              ),

              /// Modify Password Button
              InkWell(
                onTap: () => _showBottomSheet(
                  context,
                  ModifyBottomSheet(
                      username: username, password: password, userId: userId),
                ),
                child: _buildSettingsItem(Icons.edit, "Modify the password"),
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
                child: _buildSettingsItem(Icons.delete, "Delete the Password"),
              ),

              /// Change Currency Button
              InkWell(
                onTap: () => _showBottomSheet(
                  context,
                  const CurrencyBottomSheet(),
                ),
                child: _buildSettingsItem(
                    Icons.currency_exchange, "Change the Currency"),
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

  /// A helper widget to build each settings item
  Widget _buildSettingsItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 10),
              Text(text, style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Icon(Icons.arrow_forward_ios, size: 18),
        ],
      ),
    );
  }
}
