class WeeklyBudgetStatus {
  final String weekStart;
  final String weekEnd;
  final double totalSpent;
  final double? budget;
  final double? remaining;
  final bool exceeded;
  final double exceededBy;

  WeeklyBudgetStatus({
    required this.weekStart,
    required this.weekEnd,
    required this.totalSpent,
    this.budget,
    this.remaining,
    required this.exceeded,
    required this.exceededBy,
  });

  factory WeeklyBudgetStatus.fromJson(Map<String, dynamic> json) {
    return WeeklyBudgetStatus(
      weekStart: json['week_start'],
      weekEnd: json['week_end'],
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      budget: json['budget']?.toDouble(),
      remaining: json['remaining_budget']?.toDouble(),
      exceeded: json['budget_exceeded'],
      exceededBy: (json['exceeded_by'] ?? 0).toDouble(),
    );
  }
}
