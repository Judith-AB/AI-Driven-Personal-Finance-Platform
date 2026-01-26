import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetWeeklyBudgetScreen extends StatefulWidget {
  const SetWeeklyBudgetScreen({super.key});

  @override
  State<SetWeeklyBudgetScreen> createState() => _SetWeeklyBudgetScreenState();
}

class _SetWeeklyBudgetScreenState extends State<SetWeeklyBudgetScreen> {
  final TextEditingController amountController = TextEditingController();
  bool isSaving = false;

  DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1)); // Monday
  }

  Future<void> saveWeeklyBudget() async {
    if (amountController.text.isEmpty) return;

    setState(() => isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final now = DateTime.now();
    final weekStart = getWeekStart(now);

    final url =
        Uri.parse("http://10.110.214.170:8000/api/budget/weekly/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "period": "weekly",
        "amount": double.parse(amountController.text),
        "start_date": weekStart.toIso8601String().substring(0, 10),
      }),
    );

    setState(() => isSaving = false);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        mounted) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save weekly budget")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Weekly Budget"),
        backgroundColor: const Color.fromARGB(255, 5, 81, 144),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Week: ${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weekly Budget Amount",
                prefixText: "₹ ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSaving ? null : saveWeeklyBudget,
              child: isSaving
                  ? const CircularProgressIndicator()
                  : const Text("Save Weekly Budget"),
            ),
          ],
        ),
      ),
    );
  }
}
