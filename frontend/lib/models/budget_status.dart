class BudgetStatus {
  final int month;
  final int year;
  final double totalSpent;
  final double? budget;
  final double? remainingBudget;
  final bool budgetExceeded;
  final double exceededBy;

  BudgetStatus({
    required this.month,
    required this.year,
    required this.totalSpent,
    required this.budget,
    required this.remainingBudget,
    required this.budgetExceeded,
    required this.exceededBy,
  });

  factory BudgetStatus.fromJson(Map<String, dynamic> json) {
    return BudgetStatus(
      month: json['month'],
      year: json['year'],
      totalSpent: json['total_spent'].toDouble(),
      budget: json['budget'] != null ? json['budget'].toDouble() : null,
      remainingBudget:
          json['remaining_budget'] != null ? json['remaining_budget'].toDouble() : null,
      budgetExceeded: json['budget_exceeded'],
      exceededBy: json['exceeded_by'],
    );
  }
}
