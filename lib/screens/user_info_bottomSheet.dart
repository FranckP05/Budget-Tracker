import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart';

class UserBottomSheet extends StatefulWidget {
  final String username;
  final String password;
  final int userId;

  const UserBottomSheet({
    Key? key,
    required this.username,
    required this.password,
    required this.userId,
  }) : super(key: key);

  @override
  State<UserBottomSheet> createState() => _UserBottomSheetState();
}

class _UserBottomSheetState extends State<UserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController userNameController;
  final dbhelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController(text: widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Modify Your Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: userNameController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 20, right: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                labelText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
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
                        horizontal: 20, vertical: 15),
                    backgroundColor: const Color(0xff9c1c0b),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    userNameController.text = widget.username;
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    backgroundColor: const Color(0xff109710),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String userName = userNameController.text.trim();
                      try {
                        print(
                            "Updating user: ID=${widget.userId}, Name=$userName, Pwd=${widget.password}");
                        int rowsAffected = await dbhelper.updateUser(
                          widget.userId,
                          userName,
                          widget.password,
                        );
                        print("Rows affected: $rowsAffected");
                        if (rowsAffected > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Changed the username to: $userName",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          Navigator.pop(context, userName); // Return new username
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "No changes made (user not found or no update needed)",
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
                      } catch (e) {
                        print("Error updating user: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Failed to update: $e",
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
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    userNameController.dispose();
    super.dispose();
  }
}