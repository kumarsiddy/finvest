enum DownturnRection {
  SELL("SELL", "I would sell off my holdings."),
  HOLD("HOLD", "I would wait and see what happens."),
  BUY("BUY", "I would buy more holdings.");

  final String value;
  final String displayValue;

  const DownturnRection(this.value, this.displayValue);
}
