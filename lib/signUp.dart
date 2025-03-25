import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart';
import 'main.dart'; // Import the SignInPage (MyHomePage)

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key, required this.toggleTheme});

  final VoidCallback toggleTheme;
  final usernameController = TextEditingController();
  final dbhelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/welcome.png',
                      width: double.infinity,
                    ),
                    const Text(
                      "Welcome to SudoCash",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        hintText: 'Enter your username',
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    /// Gradient Button
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0968E5), Color(0xFF091970)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            String username = usernameController.text.trim();

                            if (username.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Username cannot be empty')),
                              );
                              return;
                            }

                            bool exists = await dbhelper.userExists(username);

                            if (exists) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'User "$username" already exists! Please sign in.')),
                              );
                            } else {
                              await dbhelper.insertUser(username, '');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'User "$username" created successfully!')),
                              );
                            }
                            usernameController.text = '';
                            // Navigate back to the Sign In page (MainPage)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyHomePage(toggleTheme: toggleTheme),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sign In Navigation Button
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(toggleTheme: toggleTheme),
                          ),
                        );
                      },
                      child: const Text(
                        "Already have an account? Sign In",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button (FAB) on Top-Right Corner
          Positioned(
            top: 20, // Adjust this value based on your UI
            right: 20,
            child: FloatingActionButton(
              onPressed: toggleTheme,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[900], // Dark gray for dark mode
              foregroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              child: const Icon(Icons.brightness_7),
            ),
          ),
        ],
      ),
    );
  }
}