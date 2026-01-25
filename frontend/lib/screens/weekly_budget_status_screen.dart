import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyBudgetStatusScreen extends StatefulWidget {
  const WeeklyBudgetStatusScreen({super.key});

  @override
  State<WeeklyBudgetStatusScreen> createState() =>
      _WeeklyBudgetStatusScreenState();
}

class _WeeklyBudgetStatusScreenState extends State<WeeklyBudgetStatusScreen> {
  bool isLoading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    fetchWeeklyBudgetStatus();
  }

  Future<void> fetchWeeklyBudgetStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url =
        Uri.parse("http://10.110.214.170:8000/api/budget/weekly/status/");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (data == null) {
      return const Scaffold(
        body: Center(child: Text("No weekly budget data")),
      );
    }

    final double totalSpent = (data!['total_spent'] as num).toDouble();
    final double? budget =
        data!['budget'] != null ? (data!['budget'] as num).toDouble() : null;

    double usagePercent = 0;
    if (budget != null && budget > 0) {
      usagePercent = totalSpent / budget;
      if (usagePercent > 1) usagePercent = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Budget"),
        backgroundColor: const Color.fromARGB(255, 5, 81, 144),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Weekly Budget Usage",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: usagePercent,
                      minHeight: 14,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        usagePercent > 0.9
                            ? Colors.red
                            : usagePercent > 0.7
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(usagePercent * 100).toStringAsFixed(1)}% used",
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                title: const Text("Total Spent"),
                trailing: Text("₹$totalSpent"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Weekly Budget"),
                trailing: Text(budget == null ? "Not set" : "₹$budget"),
              ),
            ),

            Card(
              child: ListTile(
                title: const Text("Remaining"),
                trailing: Text(
                  data!['remaining_budget'] == null
                      ? "N/A"
                      : "₹${data!['remaining_budget']}",
                  style: TextStyle(
                    color: data!['budget_exceeded'] ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
