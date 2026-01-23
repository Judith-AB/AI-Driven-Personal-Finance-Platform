import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController amountController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    amountController =
        TextEditingController(text: widget.expense.amount.toString());
    descriptionController =
        TextEditingController(text: widget.expense.description);
    categoryController = TextEditingController(text: widget.expense.category);
  }

  Future<void> updateExpense() async {
    setState(() => isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = Uri.parse(
      "http://10.110.214.170:8000/api/expenses/${widget.expense.id}/",
    );

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "amount": double.parse(amountController.text),
        "description": descriptionController.text,
        "category": categoryController.text,
      }),
    );

    setState(() => isSaving = false);

    if (response.statusCode == 200 && mounted) {
      Navigator.pop(context, true); // success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense"),
      backgroundColor: const Color.fromARGB(255, 5, 81, 144,)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
               labelStyle: TextStyle(color: Color.fromARGB(255, 109, 111, 114)),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : updateExpense,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text("Update Expense"),
            ),
          ],
        ),
      ),
    );
  }
}
