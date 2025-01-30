enum InvestmentPriority {
  AVOID_LOSSES("AVOID_LOSSES", "Minimize Losses (Low Risk)"),
  BALANCE_RISK("BALANCE_RISK", "Balance Risk"),
  MAXIMIZE_RETURNS("MAXIMIZE_RETURNS", "Maximize Returns (High Risk)");

  final String value;
  final String displayValue;

  const InvestmentPriority(this.value, this.displayValue);
}
