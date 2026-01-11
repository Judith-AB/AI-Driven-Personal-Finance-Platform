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

    final url = Uri.parse("http://192.168.1.8:8000/api/budget-status/");

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
      appBar: AppBar(title: const Text("Budget Status")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : status == null
              ? const Center(child: Text("No budget data"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Month: ${status!.month}/${status!.year}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text("Total Spent: ₹${status!.totalSpent}"),
                      const SizedBox(height: 10),
                      Text("Budget: ₹${status!.budget ?? 'Not set'}"),
                      const SizedBox(height: 10),
                      Text("Remaining: ₹${status!.remainingBudget ?? 'N/A'}"),
                      const SizedBox(height: 20),
                      status!.budgetExceeded
                          ?  Text(
                              "Budget Exceeded by ₹${status!.exceededBy}",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            )
                          : const Text(
                              " Within Budget",
                              style:
                                  TextStyle(color: Colors.green, fontSize: 18),
                            ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SetBudgetScreen()),
                          );

                          if (updated == true) {
                            fetchBudgetStatus(); // refresh data
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
