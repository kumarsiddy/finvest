enum DocumentType {
  STATEMENT("STATEMENT"),
  TAX_STATEMENT("TAX_STATEMENT"),
  TRADE_CONFIRMATION("TRADE_CONFIRMATION");

  final String value;

  const DocumentType(this.value);
}
