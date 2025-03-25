import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart';
import 'package:sudo_cash/screens/settings_page.dart';
import 'package:sudo_cash/category_page.dart';
import 'package:sudo_cash/screens/show_wallet_bottomSheet.dart';

// ============================================================================
// Wallet Model
// ============================================================================
class Wallet {
  final int id;
  final String name;
  final double totalAmount;
  final double limitAmount;
  final Color color;

  Wallet({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.limitAmount,
    required this.color,
  });
}

// ============================================================================
// Wallet Page Widget
// ============================================================================
class WalletPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final String name;
  final int userId;
  final String password;

  const WalletPage({
    super.key,
    required this.toggleTheme,
    required this.name,
    required this.userId,
    required this.password,
  });

  @override
  _WalletPageState createState() => _WalletPageState();
}

// ============================================================================
// Wallet Page State
// ============================================================================
class _WalletPageState extends State<WalletPage> {
  List<Wallet> wallets = [];
  final dbHelper = DatabaseHelper.instance;
  late String currentUsername;

  final List<Color> walletColors = [
    const Color(0xFFE57373),
    const Color(0xFF81C784),
    const Color(0xFF64B5F6),
    const Color(0xFFFFB74D),
    const Color(0xFF9575CD),
    const Color(0xFF4DB6AC),
    const Color(0xFFF06292),
    const Color(0xFFFFD54F),
  ];

  @override
  void initState() {
    super.initState();
    currentUsername = widget.name;
    _loadWallets();
  }

  // Load wallets from database
  Future<void> _loadWallets() async {
    final walletsData = await dbHelper.getAllWallets();
    setState(() {
      wallets =
          walletsData.map((data) {
            final limit =
                data['wallet_limit'] <= 0 ? 1.0 : data['wallet_limit'];
            return Wallet(
              id: data['walletID'],
              name: data['name_wallets'],
              totalAmount: data['total'],
              limitAmount: limit,
              color: _parseColor(data['color']),
            );
          }).toList();
    });
  }

  // Load username from database
  Future<void> _loadUsername() async {
    try {
      final userData = await dbHelper.getUserById(widget.userId);
      if (userData != null) {
        setState(() {
          currentUsername = userData['name'];
        });
      }
    } catch (e) {
      print("Error loading username: $e");
    }
  }

  // Parse color from hex string
  Color _parseColor(String colorHex) {
    try {
      String hex = colorHex.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('ff$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (e) {
      print('Error parsing color: $colorHex, Error: $e');
    }
    return Colors.blue; // Default color fallback
  }

  // Get greeting based on current time
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Good Morning, $currentUsername";
    if (hour >= 12 && hour < 17) return "Good Afternoon, $currentUsername";
    if (hour >= 17 && hour < 21) return "Good Evening, $currentUsername";
    return "Good Night, $currentUsername"; // Covers 21:00 to 4:59
  }

  String _engagingMessage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "☀️ Make today count!";
    if (hour >= 12 && hour < 17) return "⚡ Stay on top of your goals!";
    if (hour >= 17 && hour < 21) return "Keep moving forward!";
    return "🌙 Recharge for tomorrow!"; // Covers 21:00 to 4:59
  }

  // Get greeting image based on current time
  String _getGreetingImage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'assets/images/wakeUp2.png';
    if (hour >= 12 && hour < 17) return 'assets/images/afternoon.jpg';
    if (hour >= 17 && hour < 21) return 'assets/images/moon_2.jpg';
    return 'assets/images/good_night.jpg'; // Covers 21:00 to 4:59
  }

  // Show bottom sheet to add a wallet
  void _showAddWalletSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _WalletForm(
            onSubmit: (name, total, limit, color) async {
              final colorHex = '#${color.value.toRadixString(16).substring(2)}';
              try {
                await dbHelper.insertWallet(
                  name,
                  total,
                  limit,
                  colorHex,
                  widget.userId,
                );
                await _loadWallets();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add wallet: $e')),
                );
              }
            },
            colors: walletColors,
          ),
    );
  }

  // Show bottom sheet to edit a wallet
  void _showEditWalletSheet(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _WalletForm(
            onSubmit: (name, total, limit, color) async {
              final colorHex = '#${color.value.toRadixString(16).substring(2)}';
              try {
                await dbHelper.updateWallet(
                  wallets[index].id,
                  name,
                  total,
                  limit,
                  colorHex,
                );
                await _loadWallets();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update wallet: $e')),
                );
              }
            },
            initialWallet: wallets[index],
            colors: walletColors,
          ),
    );
  }

  // Confirm wallet deletion
  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Wallet'),
            content: const Text('Are you sure you want to delete this wallet?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await dbHelper.deleteWallet(wallets[index].id);
                  await _loadWallets();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // ============================================================================
  // Build Method (UI)
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SudoCash',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
        foregroundColor:
            Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Settings(
                        username: currentUsername,
                        password: widget.password,
                        userId: widget.userId,
                        onBack: _loadUsername, // Pass callback
                      ),
                ),
              );
              if (result != null && result is String) {
                setState(() {
                  currentUsername = result;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _engagingMessage(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),

            // Image Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(_getGreetingImage()),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // "My Wallets" Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                "My Wallets",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),

            // Wallets Grid
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: wallets.length,
                itemBuilder:
                    (context, index) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CategoryPage(wallet: wallets[index]),
                          ),
                        );
                      },
                      onLongPress: () => _showWalletOptions(index),
                      child: _WalletCard(wallet: wallets[index]),
                    ),
              ),
            ),

            // Add Wallet Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0968E5), Color(0xFF091970)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: InkWell(
                  onTap: _showAddWalletSheet,
                  borderRadius: BorderRadius.circular(25),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add Wallet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                      return ShowWalletBottomSheet();
                    },
                  );
        },
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  // Show options for editing or deleting a wallet
  void _showWalletOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
                title: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.deepPurpleAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditWalletSheet(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(index);
                },
              ),
            ],
          ),
    );
  }
}

// ============================================================================
// Wallet Card Widget
// ============================================================================
class _WalletCard extends StatelessWidget {
  final Wallet wallet;

  const _WalletCard({required this.wallet});

  Color _getProgressColor(double ratio) {
    if (ratio <= 0.5) return Colors.green;
    if (ratio <= 0.8) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        wallet.limitAmount > 0
            ? (wallet.totalAmount / wallet.limitAmount).clamp(0.0, 1.0)
            : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: wallet.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              wallet.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '\$${wallet.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(ratio),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${wallet.limitAmount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Wallet Form Widget (Bottom Sheet)
// ============================================================================
class _WalletForm extends StatefulWidget {
  final Function(String, double, double, Color) onSubmit;
  final Wallet? initialWallet;
  final List<Color> colors;

  const _WalletForm({
    required this.onSubmit,
    this.initialWallet,
    required this.colors,
  });

  @override
  __WalletFormState createState() => __WalletFormState();
}

class __WalletFormState extends State<_WalletForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _totalController;
  late TextEditingController _limitController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialWallet?.name ?? '',
    );
    _totalController = TextEditingController(
      text: widget.initialWallet?.totalAmount.toStringAsFixed(2) ?? '',
    );
    _limitController = TextEditingController(
      text: widget.initialWallet?.limitAmount.toStringAsFixed(2) ?? '',
    );
    _selectedColor = widget.initialWallet?.color ?? widget.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialWallet == null ? 'Add Wallet' : 'Edit Wallet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Wallet Name'),
              validator:
                  (value) => value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
              validator:
                  (value) => value!.isEmpty ? 'Please enter an amount' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _limitController,
              decoration: const InputDecoration(labelText: 'Limit Amount'),
              keyboardType: TextInputType.number,
              validator:
                  (value) => value!.isEmpty ? 'Please enter a limit' : null,
            ),
            const SizedBox(height: 16),
            Text('Choose Color', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.colors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder:
                    (context, index) => GestureDetector(
                      onTap:
                          () => setState(
                            () => _selectedColor = widget.colors[index],
                          ),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.colors[index],
                          shape: BoxShape.circle,
                          border:
                              _selectedColor == widget.colors[index]
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(widget.initialWallet == null ? 'Add' : 'Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      try {
        final total = double.parse(_totalController.text);
        final limit = double.parse(_limitController.text);
        if (total < 0 || limit <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Total must be non-negative and limit must be positive',
              ),
            ),
          );
          return;
        }
        widget.onSubmit(_nameController.text, total, limit, _selectedColor);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding wallet: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _limitController.dispose();
    super.dispose();
  }
}
