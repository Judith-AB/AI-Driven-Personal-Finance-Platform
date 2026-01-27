import 'package:flutter/material.dart';
import 'monthly_budget_status_screen.dart';
import 'weekly_budget_status_screen.dart';

class BudgetHomeScreen extends StatelessWidget {
  const BudgetHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matching your app's theme
      appBar: AppBar(
        title: const Text(
          "Finance Hub",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Track your spending",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Monthly Budget Card
            _budgetCard(
              context,
              icon: Icons.calendar_today_rounded,
              title: "Monthly Budget",
              subtitle: "Plan for the month ahead",
              accentColor: Colors.blueAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MonthlyBudgetStatusScreen()),
              ),
            ),

            const SizedBox(height: 16),

            // Weekly Budget Card
            _budgetCard(
              context,
              icon: Icons.view_week_rounded,
              title: "Weekly Budget",
              subtitle: "Manage your short-term goals",
              accentColor: Colors.greenAccent,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const WeeklyBudgetStatusScreen()),
              ),
            ),

            const Spacer(),

            const SizedBox(height: 20),
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
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Icon Container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: 20),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Forward Arrow
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
