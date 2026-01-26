import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'set_weekly_budget.dart';

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

    setState(() {
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      }
      isLoading = false;
    });
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
        body: Center(child: Text("Unable to load weekly budget")),
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
            Text(
              "Week: ${data!['week_start']} → ${data!['week_end']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            if (budget == null) ...[
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "No weekly budget set for this week.\nSet one to track your spending.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (budget != null) ...[
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
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text("Total Spent"),
                  trailing: Text("₹$totalSpent"),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Weekly Budget"),
                  trailing: Text("₹$budget"),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Remaining"),
                  trailing: Text(
                    "₹${data!['remaining_budget']}",
                    style: TextStyle(
                      color:
                          data!['budget_exceeded'] ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: data!['budget_exceeded']
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    data!['budget_exceeded']
                        ? "⚠️ Budget exceeded by ₹${(data!['exceeded_by'] as num).toDouble().toStringAsFixed(2)}"
                        : "You are within the weekly budget",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          data!['budget_exceeded'] ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            //  Set / Update Button
            ElevatedButton(
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SetWeeklyBudgetScreen(),
                  ),
                );

                if (updated == true) {
                  fetchWeeklyBudgetStatus();
                }
              },
              child: Text(budget == null
                  ? "Set Weekly Budget"
                  : "Update Weekly Budget"),
            ),
          ],
        ),
      ),
    );
  }
}
