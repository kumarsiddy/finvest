enum AnnualIncome {
  BELOW_50K("BELOW_50K", "\$0 - 50,000"),
  BETWEEN_50K_AND_100K("BETWEEN_50K_AND_100K", "\$50,001 - 100,000"),
  BETWEEN_100K_AND_250K("BETWEEN_100K_AND_250K", "\$100,001 - 250,000"),
  OVER_250K("OVER_250K", ">\$250,000");

  final String value;
  final String displayValue;

  const AnnualIncome(this.value, this.displayValue);
}
