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
    final response =
        await http.get(url, headers: {"Authorization": "Bearer $token"});

    setState(() {
      if (response.statusCode == 200) data = jsonDecode(response.body);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body:
            Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      );
    }

    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child:
                Text("No Data Found", style: TextStyle(color: Colors.white))),
      );
    }

    final double spent = (data!['total_spent'] as num).toDouble();
    final double budget =
        data!['budget'] != null ? (data!['budget'] as num).toDouble() : 0.0;
    double usage = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Weekly Budget",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
          
            _pillHeader("${data!['week_start']} → ${data!['week_end']}"),
            const SizedBox(height: 24),

            _usageHero(usage, budget),
            const SizedBox(height: 24),

            _summaryTable(spent),
            const SizedBox(height: 32),
            
            _neonButton(),
          ],
        ),
      ),
    );
  }

  Widget _pillHeader(String txt) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        txt,
        style: const TextStyle(
            color: Colors.white60, fontWeight: FontWeight.w500, fontSize: 13),
      ),
    );
  }

  Widget _usageHero(double percent, double budget) {
    Color color = percent > 0.9
        ? Colors.redAccent
        : percent > 0.7
            ? Colors.orangeAccent
            : Colors.greenAccent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1E1E), Colors.black.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Text("Weekly Limit",
              style: TextStyle(color: Colors.white38, fontSize: 14)),
          Text(
            "₹${budget.toStringAsFixed(0)}",
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 14,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${(percent * 100).toStringAsFixed(1)}% Consumed",
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _summaryTable(double spent) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _tile(Icons.arrow_upward, "Total Spent",
              "₹${spent.toStringAsFixed(2)}", Colors.orangeAccent),
          _divider(),
          _tile(
            data!['budget_exceeded']
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            "Remaining",
            "₹${data!['remaining_budget']}",
            data!['budget_exceeded'] ? Colors.redAccent : Colors.greenAccent,
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String val, Color col) {
    return ListTile(
      leading: Icon(icon, color: col, size: 20),
      title: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 14)),
      trailing: Text(val,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 50);

  Widget _neonButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.05),
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white10),
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetWeeklyBudgetScreen()),
      ).then((_) => fetchWeeklyBudgetStatus()),
      child: const Text("Adjust Weekly Settings",
          style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
