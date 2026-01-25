import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../constants/categories.dart';

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
  String selectedCategory = "";
  @override
  void initState() {
    super.initState();
    selectedCategory = widget.expense.category;

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
        "category": selectedCategory,
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
      appBar: AppBar(
          title: const Text("Edit Expense"),
          backgroundColor: const Color.fromARGB(
            255,
            5,
            81,
            144,
          )),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: const Color.fromARGB(179, 151, 151, 151)),
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: TextStyle(color: const Color.fromARGB(179, 151, 151, 151)),
              controller: descriptionController,
              decoration: const InputDecoration(
                labelStyle: TextStyle(color: Colors.white70),
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),
             const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: expenseCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
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
