class MyDaily {
  String userId;
  String dailyId;
  String name;
  String date;
  String price;
  String icon;

  MyDaily(this.userId, this.dailyId, this.name, this.date, this.price, this.icon);

  MyDaily.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        dailyId = json['dailyId'],
        name = json['name'],
        date = json['date'],
        price = json['price'],
        icon = json['icon'];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'dailyId': dailyId,
        'name': name,
        'date': date,
        'price': price,
        'icon': icon,
      };
}
