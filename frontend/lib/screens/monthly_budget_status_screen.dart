import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_status.dart';
import 'set_budget.dart';

class MonthlyBudgetStatusScreen extends StatefulWidget {
  const MonthlyBudgetStatusScreen({super.key});

  @override
  State<MonthlyBudgetStatusScreen> createState() => _BudgetStatusScreenState();
}

class _BudgetStatusScreenState extends State<MonthlyBudgetStatusScreen> {
  BudgetStatus? status;
  bool isLoading = true;
  String monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    fetchBudgetStatus();
  }

  Future<void> fetchBudgetStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    //print("MONTHLY STATUS TOKEN: $token");

    final url =
        Uri.parse("http://10.110.214.170:8000/api/budget/monthly/status/");

    print("CALLING MONTHLY STATUS API: $url");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    //  print("STATUS CODE: ${response.statusCode}");
    //print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      setState(() {
        status = BudgetStatus.fromJson(jsonDecode(response.body));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        status = null;
      });
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
              ? const Center(
                  child: Text(
                    "Unable to load monthly budget.\nPlease set a monthly budget.",
                    textAlign: TextAlign.center,
                  ),
                )
              : Builder(
                  builder: (context) {
                    double usagePercent = 0;

                    if (status!.budget != null && status!.budget! > 0) {
                      usagePercent = status!.totalSpent / status!.budget!;
                      if (usagePercent > 1) usagePercent = 1;
                    }

                    return Padding(
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
                                    "Budget Usage",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: LinearProgressIndicator(
                                      value: usagePercent,
                                      minHeight: 18,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        usagePercent > 0.9
                                            ? Colors.red
                                            : usagePercent > 0.7
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${(usagePercent * 100).toStringAsFixed(1)}% of budget used",
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          //Monthly budget details
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
                                    "Budget for ${monthName(status!.month)} ${status!.year}",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Total Spent: ₹${status!.totalSpent}",
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    status!.budget == null
                                        ? "Budget: Not set"
                                        : "Budget: ₹${status!.budget}",
                                  ),
                                  Text(
                                    "Remaining: ₹${status!.remainingBudget ?? 'N/A'}",
                                    style: TextStyle(
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
                                    ? "⚠️ Budget Exceeded by ₹${status!.exceededBy.toStringAsFixed(2)}"
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
                    );
                  },
                ),
    );
  }
}
