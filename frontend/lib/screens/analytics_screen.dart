import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyAnalyticsTab extends StatelessWidget {
  final List<Expense> expenses;

  const DailyAnalyticsTab({super.key, required this.expenses});

  Map<String, double> getDailySummary() {
    final Map<String, double> dailyTotals = {};

    for (var e in expenses) {
      final d = e.createdAt;
      final key = "${d.day}/${d.month}";

      dailyTotals[key] = (dailyTotals[key] ?? 0) + e.amount;
    }

    return dailyTotals;
  }

  @override
  Widget build(BuildContext context) {
    final dailySummary = getDailySummary();

    if (dailySummary.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final labels = dailySummary.keys.toList();
    final values = dailySummary.values.toList();

    final maxY = values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Daily Spending Trend",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (values.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          labels[index],
                          style:
                              const TextStyle(fontSize: 8, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 250,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        "₹${value.toInt()}",
                        style: const TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      );
                    },
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    values.length,
                    (i) => FlSpot(i.toDouble(), values[i]),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Daily Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...dailySummary.entries.map((entry) {
          return Card(
            child: ListTile(
              title: Text(entry.key),
              trailing: Text(
                "₹${entry.value}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        })
      ],
    );
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

  Map<String, double> getWeeklySummary() {
    final Map<String, double> weeklyTotals = {};

    for (var e in expenses) {
      final week = getWeekNumber(e.createdAt);
      final key = "W$week-${e.createdAt.year}";

      weeklyTotals[key] = (weeklyTotals[key] ?? 0) + e.amount;
    }

    return weeklyTotals;
  }

  @override
  Widget build(BuildContext context) {
    final weeklySummary = getWeeklySummary();

    if (weeklySummary.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final labels = weeklySummary.keys.toList();
    final values = weeklySummary.values.toList();
    final maxY = values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Weekly Spending Trend",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (values.length - 1).toDouble(),
              minY: 0,
              maxY: maxY + 100,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(labels[i],
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) => Text("₹${value.toInt()}",
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    values.length,
                    (i) => FlSpot(i.toDouble(), values[i]),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Weekly Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...weeklySummary.entries.map((e) {
          return Card(
            child: ListTile(
              title: Text(e.key),
              trailing: Text(
                "₹${e.value}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        })
      ],
    );
  }
}

class MonthlyAnalyticsTab extends StatelessWidget {
  final List<Expense> expenses;

  const MonthlyAnalyticsTab({super.key, required this.expenses});

  Map<String, double> getMonthlySummary() {
    final Map<String, double> monthlyTotals = {};

    for (var e in expenses) {
      final key = "${e.createdAt.month}/${e.createdAt.year}";
      monthlyTotals[key] = (monthlyTotals[key] ?? 0) + e.amount;
    }

    return monthlyTotals;
  }

  @override
  Widget build(BuildContext context) {
    final monthlySummary = getMonthlySummary();

    if (monthlySummary.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final labels = monthlySummary.keys.toList();
    final values = monthlySummary.values.toList();
    final maxY = values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Monthly Spending Trend",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (values.length - 1).toDouble(),
              minY: 0,
              maxY: maxY + 100,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i < 0 || i >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(labels[i],
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: maxY / 4,
                    getTitlesWidget: (value, meta) => Text("₹${value.toInt()}",
                        style: const TextStyle(fontSize: 10)),
                  ),
                ),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    values.length,
                    (i) => FlSpot(i.toDouble(), values[i]),
                  ),
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          "Monthly Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...monthlySummary.entries.map((e) {
          return Card(
            child: ListTile(
              title: Text(e.key),
              trailing: Text(
                "₹${e.value}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        })
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
        appBar: AppBar(
          title: const Text("Analytics"),
          bottom: const TabBar(
            tabs: [
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
