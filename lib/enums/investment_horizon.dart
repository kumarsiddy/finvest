enum InvestmentHorizon {
  SHORT_TERM("SHORT_TERM", "Short Term (0-2 years)"),
  MEDIUM_TERM("MEDIUM_TERM", "Medium Term (2-5 years)"),
  LONG_TERM("LONG_TERM", "Long Term (5+ years)");

  final String value;
  final String displayValue;

  const InvestmentHorizon(this.value, this.displayValue);
}
