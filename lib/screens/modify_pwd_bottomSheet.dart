import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sudo_cash/database/database_helper.dart';

class ModifyBottomSheet extends StatefulWidget {
  final String username;
  final String password;
  final int userId;
  const ModifyBottomSheet({
    Key? key,
    required this.username,
    required this.password,
    required this.userId,
  }) : super(key: key);

  @override
  State<ModifyBottomSheet> createState() => _ModifyBottomSheetState();
}

final _formKey = GlobalKey<FormState>();
final modifiedPwdController = TextEditingController();
final confirmModifPwdController = TextEditingController();
final dbhelper=DatabaseHelper.instance;

class _ModifyBottomSheetState extends State<ModifyBottomSheet> {
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
              "Modify your Password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: modifiedPwdController,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 20, right: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                hintText: 'Enter your new Password',
                labelText: 'New password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Password';
                }
                return null;
              },
            ),
            const SizedBox(height: 10), // SizedBox for spacing
            TextFormField(
              controller: confirmModifPwdController,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 20, right: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                hintText: 'Confirm your modified Password',
                labelText: 'Confirm',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid Password';
                }
                return null;
              },
            ),
            const SizedBox(height: 10), //Size box for spacing
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
                    Fluttertoast.showToast(msg: "Cancelled");
                    Navigator.pop(context);
                    modifiedPwdController.text = "";
                    confirmModifPwdController.text = "";
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
                  onPressed: () async{
                    String modifiedPwd = modifiedPwdController.text;
                    String confirmPwd = confirmModifPwdController.text;
                    if (modifiedPwd == confirmPwd) {
                      if (_formKey.currentState!.validate()) {
                        await dbhelper.updateUser(widget.userId, widget.username, modifiedPwd);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Your password is : $modifiedPwd",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                        Navigator.pop(context); // Close the bottom sheet
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Your password doesn't match!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.redAccent,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                    modifiedPwdController.text = "";
                    confirmModifPwdController.text = "";
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
}
