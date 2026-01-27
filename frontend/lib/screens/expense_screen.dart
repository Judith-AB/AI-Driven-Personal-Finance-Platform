import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense.dart';
import 'budget_home_screen.dart';
import 'login_screen.dart';
import 'add_expenses.dart';
import 'edit_expense_screen.dart';
import 'analytics_screen.dart';

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

  Map<String, List<Expense>> groupExpensesByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> grouped = {};
    for (var expense in expenses) {
      final localDate = expense.createdAt.toLocal();
      // Professional Date Format: "24 Jan 2026"
      final date =
          "${localDate.day} ${_getMonthName(localDate.month)} ${localDate.year}";
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(expense);
    }
    return grouped;
  }

  String _getMonthName(int month) => [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ][month - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "All Spending",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined,
                color: Colors.blueAccent),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BudgetHomeScreen())),
          ),
          IconButton(
            icon:
                const Icon(Icons.analytics_outlined, color: Colors.greenAccent),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AnalyticsScreen(expenses: expenses))),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent))
          : expenses.isEmpty
              ? const Center(
                  child: Text("No expenses found",
                      style: TextStyle(color: Colors.white38)))
              : _buildExpenseList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          final added = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
          if (added == true) fetchExpenses();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildExpenseList() {
    final groupedExpenses = groupExpensesByDate(expenses);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: groupedExpenses.length,
      itemBuilder: (context, index) {
        String date = groupedExpenses.keys.elementAt(index);
        List<Expense> dayExpenses = groupedExpenses[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10, left: 4),
              child: Text(
                date,
                style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1),
              ),
            ),
            ...dayExpenses.map((e) => _expenseCard(e)),
          ],
        );
      },
    );
  }

  Widget _expenseCard(Expense e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A), // Modern Deep Grey
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Icon(_getCategoryIcon(e.category),
              color: Colors.blueAccent, size: 20),
        ),
        title: Text(
          e.description,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          e.category,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        trailing: Text(
          "₹${e.amount.toStringAsFixed(0)}",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onTap: () async {
          final updated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e)),
          );
          if (updated == true) fetchExpenses();
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'travel':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
