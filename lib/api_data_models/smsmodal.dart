class smsmodal {
  String date;
  num amount;
  String name;
  String address;
  String body;
  smsmodal(this.date, this.amount, this.name, this.address, this.body);
  Map toJson() => {
        'date': date,
        'amount': amount,
        'name': name,
        'address': address,
        'body': body,
      };
  factory smsmodal.fromJson(dynamic json) {
    return smsmodal(json['date'], json['amount'] as num, json['name'],
        json['address'], json['body']);
  }
}
