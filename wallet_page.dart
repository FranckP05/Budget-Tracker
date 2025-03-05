import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour récupérer l’heure actuelle

void main() {
  runApp(MyBudgetApp());
}

class MyBudgetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mybudget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> wallets = []; // Liste des wallets

  // Fonction pour obtenir le message de bienvenue
  String getGreetingMessage() {
    int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 12) {
      return "Bonjour !";
    } else if (hour >= 12 && hour < 18) {
      return "Bonsoir !";
    } else {
      return "Bonne nuit !";
    }
  }

  // Fonction pour afficher un SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Fonction pour afficher le formulaire d’ajout de wallet
  void _showAddWalletDialog() {
    TextEditingController walletController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ajouter un wallet"),
          content: TextField(
            controller: walletController,
            decoration: InputDecoration(hintText: "Nom du wallet"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (walletController.text.isNotEmpty) {
                  setState(() {
                    wallets.add(walletController.text);
                  });
                  _showSnackBar("Wallet ajouté avec succès !");
                  Navigator.pop(context);
                }
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher les options de modification/suppression
  void _showWalletOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text("Modifier"),
              onTap: () {
                Navigator.pop(context);
                _editWallet(index);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Supprimer"),
              onTap: () {
                setState(() {
                  wallets.removeAt(index);
                });
                _showSnackBar("Wallet supprimé !");
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour modifier un wallet
  void _editWallet(int index) {
    TextEditingController walletController = TextEditingController();
    walletController.text = wallets[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier le wallet"),
          content: TextField(
            controller: walletController,
            decoration: InputDecoration(hintText: "Nom du wallet"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (walletController.text.isNotEmpty) {
                  setState(() {
                    wallets[index] = walletController.text;
                  });
                  _showSnackBar("Wallet modifié !");
                  Navigator.pop(context);
                }
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("mybudget"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreetingMessage(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: wallets.isEmpty
                  ? Center(child: Text("Aucun wallet ajouté"))
                  : ListView.builder(
                      itemCount: wallets.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPress: () => _showWalletOptions(index),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(wallets[index]),
                              leading: Icon(Icons.account_balance_wallet),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _showAddWalletDialog,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Ajouter un wallet"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
