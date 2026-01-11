import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final budgetController = TextEditingController();
  bool isSaving = false;

  Future<void> saveBudget() async {
    setState(() => isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    final url = Uri.parse("http://192.168.1.8:8000/api/budgets/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "month": month,
        "year": year,
        "amount": double.parse(budgetController.text),
      }),
    );

    setState(() => isSaving = false);

    if (response.statusCode == 201 && mounted) {
      Navigator.pop(context, true); // success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Monthly Budget")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Budget for ${DateTime.now().month}/${DateTime.now().year}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Budget Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSaving ? null : saveBudget,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text("Save Budget"),
            ),
          ],
        ),
      ),
    );
  }
}
