class Asset {
  String? cusip;
  String? bondType;
  String? asOfTimestamp;
  String? maturityDate;
  String? duration;
  String? type;
  String? yieldToMaturityFormatted;
  int? minimumOrderQuantity;
  double? minimumOrderValue;

  Asset(
      {this.cusip,
      this.bondType,
      this.asOfTimestamp,
      this.maturityDate,
      this.duration,
      this.type,
      this.yieldToMaturityFormatted,
      this.minimumOrderQuantity,
      this.minimumOrderValue});

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      cusip: json['cusip'],
      bondType: json['bond_type'],
      asOfTimestamp: json['as_of_timestamp'],
      maturityDate: json['maturity_date'],
      duration: json['duration'],
      type: json['type'],
      yieldToMaturityFormatted: json['yield_to_maturity_formatted'],
      minimumOrderQuantity: json['minimum_order_quantity']?.toInt(),
      minimumOrderValue: (json['minimum_order_value'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cusip': cusip,
      'bond_type': bondType,
      'as_of_timestamp': asOfTimestamp,
      'maturity_date': maturityDate,
      'duration': duration,
      'type': type,
      'yield_to_maturity_formatted': yieldToMaturityFormatted,
      'minimum_order_quantity': minimumOrderQuantity,
      'minimum_order_value': minimumOrderValue,
    };
  }
}
