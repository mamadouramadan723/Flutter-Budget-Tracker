class DailyTransaction {
  String userId;
  String transactionId;
  String transactionName;
  String transactionDescription;
  String date;
  int timeStamp;
  double transactionPrice;
  String icon;

  DailyTransaction(
      this.userId,
      this.transactionId,
      this.transactionName,
      this.transactionDescription,
      this.date,
      this.transactionPrice,
      this.timeStamp,
      this.icon);

  DailyTransaction.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        transactionId = json['dailyId'],
        transactionName = json['name'],
        transactionDescription = json['transactionDescription'],
        date = json['date'],
        timeStamp = json['timeStamp'],
        transactionPrice = json['price'],
        icon = json['icon'];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'dailyId': transactionId,
        'name': transactionName,
        'transactionDescription': transactionDescription,
        'date': date,
        'price': transactionPrice,
        'timeStamp': timeStamp,
        'icon': icon,
      };
}
