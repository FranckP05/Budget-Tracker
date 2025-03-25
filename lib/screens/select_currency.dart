import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CurrencyBottomSheet extends StatefulWidget {
  const CurrencyBottomSheet({Key? key}) : super(key: key);

  @override
  State<CurrencyBottomSheet> createState() => _CurrencyBottomSheetState();
}

class _CurrencyBottomSheetState extends State<CurrencyBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCurrency;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Choose Your Currency",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildCurrencyRadioButton("Dollar", setState),
                    _buildCurrencyRadioButton("XAF", setState),
                    _buildCurrencyRadioButton("Euro", setState),
                  ],
                ),
                if (_showError)
                  const Text(
                    "Please select a currency",
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
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
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: "Cancelled!");
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
                      onPressed: () {
                        if (_selectedCurrency != null) {
                          Navigator.pop(context, _selectedCurrency);
                          Fluttertoast.showToast(
                              msg: "Currency set to: $_selectedCurrency");
                        } else {
                          setState(() {
                            _showError = true;
                          });
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
      },
    );
  }

  Widget _buildCurrencyRadioButton(String currency, StateSetter setState) {
    return Row(
      children: [
        Radio<String>(
          value: currency,
          groupValue: _selectedCurrency,
          onChanged: (value) {
            setState(() {
              _selectedCurrency = value;
              _showError = false; // Hide error when a currency is selected
            });
          },
        ),
        Text(currency),
      ],
    );
  }
}
