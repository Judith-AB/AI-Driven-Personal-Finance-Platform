import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import 'budget_status_screen.dart';
import 'login_screen.dart';
import 'add_expenses.dart';
import 'edit_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
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
            color: Colors.black,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetStatusScreen()),
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
              : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditExpenseScreen(expense: e),
                            ),
                          );

                          if (updated == true) {
                            fetchExpenses(); // refresh list
                          }
                        },
                        tileColor: const Color.fromARGB(255, 0, 0, 0),
                        title: Text(
                          e.description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          e.category,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 139, 139, 139)),
                        ),
                        trailing: Text(
                          "₹${e.amount}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );

          if (added == true) {
            fetchExpenses();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
