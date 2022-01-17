class MyUser {
  String userId;
  String name;
  String dateOfBirth;
  String phoneNumber;
  String mail;
  String imageUrl;
  String creditScore;

  MyUser(this.userId, this.name, this.dateOfBirth, this.phoneNumber, this.mail,
      this.imageUrl, this.creditScore);

  
  
  MyUser.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        name = json['name'],
        dateOfBirth = json['dateOfBirth'],
        phoneNumber = json['phoneNumber'],
        mail = json['mail'],
        imageUrl = json['imageUrl'],
        creditScore = json['creditScore'];

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
        'mail': mail,
        'imageUrl': imageUrl,
        'creditScore': creditScore,
      };
}
