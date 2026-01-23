import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_status.dart';
import 'set_budget.dart';

class BudgetStatusScreen extends StatefulWidget {
  const BudgetStatusScreen({super.key});

  @override
  State<BudgetStatusScreen> createState() => _BudgetStatusScreenState();
}

class _BudgetStatusScreenState extends State<BudgetStatusScreen> {
  BudgetStatus? status;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBudgetStatus();
  }

  Future<void> fetchBudgetStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = Uri.parse("http://10.110.214.170:8000/api/budget-status/");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        status = BudgetStatus.fromJson(jsonDecode(response.body));
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Status"),
        backgroundColor: const Color.fromARGB(255, 5, 81, 144),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : status == null
              ? const Center(child: Text("No budget data"))
              : Padding(
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
                            children: [
                              Text(
                                "Budget for ${status!.month}/${status!.year}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text("Total Spent: ₹${status!.totalSpent}",
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Text("Budget: ₹${status!.budget ?? 'Not set'}",
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 8),
                              Text(
                                "Remaining: ₹${status!.remainingBudget ?? 'N/A'}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: status!.budgetExceeded
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        color: status!.budgetExceeded
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            status!.budgetExceeded
                                ? "⚠️ Budget Exceeded by ₹${status!.exceededBy} "
                                : "You are within budget",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: status!.budgetExceeded
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SetBudgetScreen(),
                            ),
                          );

                          if (updated == true) {
                            fetchBudgetStatus();
                          }
                        },
                        child: const Text("Set / Update Budget"),
                      ),
                    ],
                  ),
                ),
    );
  }
}
