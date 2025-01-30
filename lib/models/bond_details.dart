class BondDetails {
  String? bondType;
  String? asOfTimestamp;
  String? maturityDate;
  int? minimumOrderQuantity;
  double? minimumOrderValue;

  BondDetails();

  BondDetails.fromParams(
    this.bondType,
    this.asOfTimestamp,
    this.maturityDate,
    this.minimumOrderQuantity,
    this.minimumOrderValue,
  );

  BondDetails.fromJson(Map<String, dynamic> json) {
    bondType = json['bond_type'];
    asOfTimestamp = json['as_of_timestamp'];
    maturityDate = json['maturity_date'];
    minimumOrderQuantity = json['minimum_order_quantity'];
    if (json['minimum_order_value'] != null) {
      minimumOrderValue = json['minimum_order_value']['amount'];
    }
  }
}
