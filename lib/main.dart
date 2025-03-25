import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:sudo_cash/database/database_helper.dart';
import 'package:sudo_cash/providers/expense_provider.dart';
import 'package:sudo_cash/signUp.dart';
import 'package:sudo_cash/wallet_page.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Login Page',
        theme: ThemeData(fontFamily: 'Inter', brightness: Brightness.light),
        darkTheme: ThemeData(fontFamily: 'Inter', brightness: Brightness.dark),
        themeMode: _themeMode,
        home: MyHomePage(toggleTheme: _toggleTheme),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.toggleTheme});

  final VoidCallback toggleTheme;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbhelper = DatabaseHelper.instance;
  final userController = TextEditingController();
  final pwdController = TextEditingController();
  int count = 0;

  @override
  void dispose() {
    userController.dispose();
    pwdController.dispose();
    super.dispose();
  }

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
                      'assets/images/login_image.png',
                      width: double.infinity,
                    ),
                    const Text(
                      "Log in to your account",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: userController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                        hintText: 'Enter your username',
                        labelText: 'Username',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: pwdController,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
                        hintText: 'Your Password',
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF45EE67), Color(0xFF389F09)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            String myUser = userController.text;
                            String myPwd = pwdController.text;
                            List<Map<String, dynamic>> credentials =
                                await dbhelper.getUsersWithCredentials(myUser, myPwd);
                            if (credentials.isNotEmpty) {
                              int userId = credentials.first['UserID'];
                              String userpwd = credentials.first['pwd'];
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WalletPage(
                                    toggleTheme: widget.toggleTheme,
                                    name: myUser,
                                    userId: userId,
                                    password: userpwd,
                                  ),
                                ),
                              );
                            } else {
                              if (count < 3) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Your information doesn't match!")),
                                );
                                setState(() => count++);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage(toggleTheme: widget.toggleTheme),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(toggleTheme: widget.toggleTheme),
                          ),
                        );
                      },
                      child: const Text("Don't have an account? Sign Up", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: widget.toggleTheme,
              backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.grey[800],
              child: Icon(
                Icons.brightness_6,
                color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}