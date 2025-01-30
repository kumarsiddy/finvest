class UserAgreement {
  String? agreementId;
  String? type;
  String? url;

  UserAgreement();

  UserAgreement.fromParams(this.agreementId, this.type, this.url);

  UserAgreement.fromJson(Map<String, dynamic> json) {
    agreementId = json['agreement_id'];
    type = json['type'];
    url = json['url'];
  }
}
