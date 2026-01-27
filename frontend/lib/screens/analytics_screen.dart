import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsView extends StatelessWidget {
  final String title;
  final Map<String, double> data;
  final Color accentColor;

  const AnalyticsView(
      {super.key,
      required this.title,
      required this.data,
      required this.accentColor});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty)
      return const Center(
          child: Text("No data recorded",
              style: TextStyle(color: Colors.white24)));

    final labels = data.keys.toList();
    final values = data.values.toList();
    

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        Container(
          height: 280,
          padding:
              const EdgeInsets.only(top: 24, right: 20, left: 10, bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.white.withOpacity(0.05), strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int i = value.toInt();
                      if (i < 0 || i >= labels.length)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(labels[i],
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 10)),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                      values.length, (i) => FlSpot(i.toDouble(), values[i])),
                  isCurved: true,
                  gradient: LinearGradient(
                      colors: [accentColor, accentColor.withOpacity(0.6)]),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: Colors.black,
                      strokeWidth: 2,
                      strokeColor: accentColor,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.15),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),
        const Text("Details",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        ...data.entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_graph_rounded, color: accentColor, size: 20),
                  const SizedBox(width: 12),
                  Text(entry.key,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 15)),
                  const Spacer(),
                  Text("₹${entry.value.toStringAsFixed(0)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            )),
      ],
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const AnalyticsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Analytics",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.blueAccent,
            unselectedLabelColor: Colors.white38,
            labelColor: Colors.blueAccent,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: "Daily"),
              Tab(text: "Weekly"),
              Tab(text: "Monthly"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DailyAnalyticsTab(expenses: expenses),
            WeeklyAnalyticsTab(expenses: expenses),
            MonthlyAnalyticsTab(expenses: expenses),
          ],
        ),
      ),
    );
  }
}

class DailyAnalyticsTab extends StatelessWidget {
  final List<Expense> expenses;
  const DailyAnalyticsTab({super.key, required this.expenses});

  Map<String, double> getSummary() {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      final localDate = e.createdAt.toLocal();
      final key = "${localDate.day}/${localDate.month}";
      totals[key] = (totals[key] ?? 0) + e.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsView(
        title: "Daily Spending Trend",
        data: getSummary(),
        accentColor: Colors.blueAccent);
  }
}

class WeeklyAnalyticsTab extends StatelessWidget {
  final List<Expense> expenses;
  const WeeklyAnalyticsTab({super.key, required this.expenses});

  int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final diff = date.difference(firstDayOfYear).inDays;
    return ((diff + firstDayOfYear.weekday) / 7).ceil();
  }

  Map<String, double> getSummary() {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      final week = getWeekNumber(e.createdAt.toLocal());
      final key = "W$week-${e.createdAt.year}";
      totals[key] = (totals[key] ?? 0) + e.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsView(
        title: "Weekly Spending Trend",
        data: getSummary(),
        accentColor: Colors.greenAccent);
  }
}

class MonthlyAnalyticsTab extends StatelessWidget {
  final List<Expense> expenses;
  const MonthlyAnalyticsTab({super.key, required this.expenses});

  Map<String, double> getSummary() {
    final Map<String, double> totals = {};
    for (var e in expenses) {
      final key =
          "${e.createdAt.toLocal().month}/${e.createdAt.toLocal().year}";
      totals[key] = (totals[key] ?? 0) + e.amount;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsView(
        title: "Monthly Spending Trend",
        data: getSummary(),
        accentColor: Colors.purpleAccent);
  }
}
