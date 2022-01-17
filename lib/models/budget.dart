class Budget {
  String userId;
  String budgetId;
  String name;
  String price;
  String total;
  String date;
  String color;

  Budget(this.userId, this.budgetId, this.name, this.price, this.total,
      this.date, this.color);

  Budget.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        budgetId = json['budgetId'],
        name = json['name'],
        price = json['price'],
        total = json['total'],
        date = json['date'],
        color = json['color'];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'budgetId': budgetId,
        'name': name,
        'price': price,
        'total': total,
        'date': date,
        'color': color,
      };
}
