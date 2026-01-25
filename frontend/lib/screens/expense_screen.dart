import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/screens/budget_home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import 'login_screen.dart';
import 'add_expenses.dart';
import 'edit_expense_screen.dart';
import 'analytics_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));

    final diff = date.difference(firstMonday).inDays;
    return (diff / 7).floor() + 1;
  }
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> expenses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      logout();
      return;
    }

    final url = Uri.parse("http://10.110.214.170:8000/api/expenses/");

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        expenses = data.map((e) => Expense.fromJson(e)).toList();
        isLoading = false;
      });
    } else if (response.statusCode == 401) {
      logout();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Map<String, List<Expense>> groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};

    for (var expense in expenses) {
      final date =
          "${expense.createdAt.day}-${expense.createdAt.month}-${expense.createdAt.year}";

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(expense);
    }

    return grouped;
  }

  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysOffset = firstDayOfYear.weekday - 1;
    final firstMonday = firstDayOfYear.subtract(Duration(days: daysOffset));

    final diff = date.difference(firstMonday).inDays;
    return (diff / 7).floor() + 1;
  }

  Map<String, double> getWeeklySummary(List<Expense> expenses) {
    final Map<String, double> weeklyTotals = {};

    for (var expense in expenses) {
      final week = getWeekNumber(expense.createdAt);
      final key = "Week $week - ${expense.createdAt.year}";

      weeklyTotals[key] = (weeklyTotals[key] ?? 0) + expense.amount;
    }

    return weeklyTotals;
  }

  Map<String, double> getMonthlySummary(List<Expense> expenses) {
    final Map<String, double> monthlyTotals = {};

    for (var expense in expenses) {
      final monthlist = {
        1: 'January',
        2: 'February',
        3: 'March',
        4: 'April',
        5: 'May',
        6: 'June',
        7: 'July',
        8: 'August',
        9: 'September',
        10: 'October',
        11: 'November',
        12: 'December'
      };

      final month = expense.createdAt.month;
      final monthname = monthlist[month];
      final year = expense.createdAt.year;

      final key = "$monthname $year";

      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + expense.amount;
    }

    return monthlyTotals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 81, 144),
        title: const Text("My Expenses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Colors.black,
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );

              if (added == true) {
                fetchExpenses(); // refresh list
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            color: const Color.fromARGB(255, 0, 0, 0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetHomeScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            color: const Color.fromARGB(255, 0, 0, 0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyticsScreen(expenses: expenses),
                ),
              );
            },
          ),
      
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.black,
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
              ? const Center(child: Text("No expenses found"))
              : Builder(
                  builder: (context) {
                    final groupedExpenses = groupExpensesByDate(expenses);

                    return ListView(
                      children: [
                        ...groupedExpenses.entries.map((entry) {
                          final date = entry.key;
                          final dayExpenses = entry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...dayExpenses.map((e) {
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    tileColor: Colors.black,
                                    title: Text(e.description),
                                    subtitle: Text(e.category),
                                    trailing: Text(
                                      "₹${e.amount}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onTap: () async {
                                      final updated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EditExpenseScreen(expense: e),
                                        ),
                                      );

                                      if (updated == true) {
                                        fetchExpenses();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  },
                ),
    );
  }
}
