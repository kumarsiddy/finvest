class AffiliatedExchange {
  final String value;
  final String displayValue;

  const AffiliatedExchange(this.value, this.displayValue);

  static const List<AffiliatedExchange> ALL = [
    AffiliatedExchange("XNYS", "XNYS"),
    AffiliatedExchange("XNAS", "XNAS"),
    AffiliatedExchange("XNDQ", "XNDQ"),
    AffiliatedExchange("XNFI", "XNFI"),
    AffiliatedExchange("XNGS", "XNGS"),
    AffiliatedExchange("XNIM", "XNIM"),
  ];

  static AffiliatedExchange? findByValue(String value) {
    try {
      return ALL.firstWhere((element) => element.value == value);
    } catch (e) {
      return null;
    }
  }
}
