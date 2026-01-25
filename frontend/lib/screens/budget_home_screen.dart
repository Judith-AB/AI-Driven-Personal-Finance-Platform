import 'package:flutter/material.dart';
import 'monthly_budget_status_screen.dart';
import 'weekly_budget_status_screen.dart';

class BudgetHomeScreen extends StatelessWidget {
  const BudgetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Budgets"),
        backgroundColor: const Color.fromARGB(255, 5, 81, 144),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _budgetCard(
              context,
              icon: Icons.calendar_month,
              title: "Monthly Budget",
              subtitle: "View current month budget",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MonthlyBudgetStatusScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _budgetCard(
              context,
              icon: Icons.date_range,
              title: "Weekly Budget",
              subtitle: "View current week budget",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeeklyBudgetStatusScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
