import 'package:flutter/material.dart';
import 'package:sudo_cash/database/database_helper.dart';
import 'package:sudo_cash/screens/expense_presentation_screen.dart';
import 'package:sudo_cash/wallet_page.dart';

class CategoryPage extends StatefulWidget {
  final Wallet wallet;

  const CategoryPage({Key? key, required this.wallet}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> categories = [];
  final List<Color> categoryColors = [
    const Color(0xFFE57373),
    const Color(0xFF81C784),
    const Color(0xFF64B5F6),
    const Color(0xFFFFB74D),
    const Color(0xFF9575CD),
    const Color(0xFF4DB6AC),
    const Color(0xFFF06292),
    const Color(0xFFFFD54F),
  ];

  final Map<String, IconData> categoryIcons = {
    'food': Icons.fastfood,
    'travel': Icons.flight,
    'shopping': Icons.shopping_cart,
    'entertainment': Icons.movie,
    'bills': Icons.receipt,
    'transport': Icons.directions_car,
    'health': Icons.local_hospital,
    'education': Icons.school,
    'gifts': Icons.card_giftcard,
    'misc': Icons.category,
  };
  final IconData defaultIcon = Icons.category;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final data = await dbHelper.getCategoriesByWallet(widget.wallet.id);
    setState(() {
      categories = data;
    });
  }

  IconData _getCategoryIcon(String categoryName) {
    final nameLower = categoryName.toLowerCase().trim();
    return categoryIcons[nameLower] ?? defaultIcon;
  }

  void _showAddCategorySheet() {
    String name = '';
    Color selectedColor = categoryColors[0];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Add Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: "Category Name", border: OutlineInputBorder()),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 20),
              const Text("Select Color", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryColors.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = categoryColors[index]),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: categoryColors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == categoryColors[index] ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await dbHelper.insertCategory(
                      name,
                      '#${selectedColor.value.toRadixString(16).substring(2)}',
                      widget.wallet.id,
                    );
                    _loadCategories();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Category added successfully"), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Add Category"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text("Edit Category"),
            onTap: () {
              Navigator.pop(context);
              _editCategory(index);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text("Delete Category"),
            onTap: () async {
              await dbHelper.deleteCategory(categories[index]['categoryID']);
              _loadCategories();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Category deleted successfully"), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
    );
  }

  void _editCategory(int index) {
    String name = categories[index]['name'];
    Color selectedColor = Color(int.parse(categories[index]['color'].replaceFirst('#', 'ff'), radix: 16));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Category", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(labelText: "Category Name", border: OutlineInputBorder()),
                controller: TextEditingController(text: name),
                onChanged: (value) => name = value,
              ),
              const SizedBox(height: 20),
              const Text("Select Color", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryColors.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => setModalState(() => selectedColor = categoryColors[index]),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: categoryColors[index],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == categoryColors[index] ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (name.isNotEmpty) {
                    await dbHelper.updateCategory(
                      categories[index]['categoryID'],
                      name,
                      '#${selectedColor.value.toRadixString(16).substring(2)}',
                    );
                    _loadCategories();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Category updated successfully"), backgroundColor: Colors.green),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Save Changes"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
        foregroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
        elevation: 1,
        title: Text(widget.wallet.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.category), text: "Categories"),
            Tab(icon: Icon(Icons.bar_chart), text: "Statistics"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      width: 150,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xfffc4a1a), Color(0xfff7b733)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: InkWell(
                        onTap: _showAddCategorySheet,
                        borderRadius: BorderRadius.circular(25),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 20),
                              SizedBox(width: 4),
                              Text(
                                'Add Category',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final icon = _getCategoryIcon(categories[index]['name']);
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpensePresentationScreen(
                                walletName: widget.wallet.name,
                                categoryName: categories[index]['name'],
                                walletId: widget.wallet.id,
                                categoryId: categories[index]['categoryID'],
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadCategories();
                          }
                        },
                        onLongPress: () => _showCategoryOptions(index),
                        child: Card(
                          color: Color(int.parse(categories[index]['color'].replaceFirst('#', 'ff'), radix: 16)),
                          elevation: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, color: Colors.white, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                categories[index]['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                '\$${categories[index]['totalAmount'].toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Center(child: Text("Statistics Coming Soon")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense form not implemented yet')),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}