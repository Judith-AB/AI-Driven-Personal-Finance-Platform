class Expense {
  final int id;
  final double amount;
  final String description;
  final String category;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
