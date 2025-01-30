class Referral {
  String? name;
  String? status;
  String? referralDate;
  String? activatedDate;

  Referral({this.name, this.status, this.referralDate, this.activatedDate});

  factory Referral.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final status = json['status'];
    final referralDate = json['referralDate'];
    final activatedDate = json['activatedDate'];
    return Referral(
        name: name,
        status: status,
        referralDate: referralDate,
        activatedDate: activatedDate);
  }
}
