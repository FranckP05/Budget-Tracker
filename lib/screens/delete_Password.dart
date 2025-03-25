import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart';

AlertDialog buildDeleteConfirmationDialog(BuildContext context, int userId) {
  final dbHelper = DatabaseHelper.instance;

  return AlertDialog(
    title: const Text("Confirm Deletion"),
    content: const Text("Are you sure you want to delete your password?"),
    actions: <Widget>[
      TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          Navigator.of(context).pop(); // Close the dialog
        },
      ),
      TextButton(
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
        onPressed: () async {
          try {
            // Fetch current user data to keep the username intact
            final userData = await dbHelper.getUserById(userId);
            if (userData == null) {
              throw Exception("User not found");
            }
            String currentUsername = userData['name'];

            // Update password to empty string
            int rowsAffected = await dbHelper.updateUser(
              userId,
              currentUsername, // Keep username unchanged
              '', // Set password to empty string
            );

            if (rowsAffected > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Password deleted successfully",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "No password found to delete or no change made",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
            Navigator.of(context).pop(); // Close the dialog
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Failed to delete password: $e",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      ),
    ],
  );
}