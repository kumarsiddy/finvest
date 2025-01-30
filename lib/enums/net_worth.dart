enum NetWorth {
  BELOW_50K("BELOW_50K", "\$0 - 50,000"),
  BETWEEN_50K_AND_200K("BETWEEN_50K_AND_200K", "\$50,001 - 200,000"),
  BETWEEN_200K_AND_1M("BETWEEN_200K_AND_1M", "\$200,001 - 1,000,000"),
  BETWEEN_1M_AND_5M("BETWEEN_1M_AND_5M", "\$1,000,001 - 5,000,000"),
  OVER_5M("OVER_5M", ">\$5,000,000");

  final String value;
  final String displayValue;

  const NetWorth(this.value, this.displayValue);
}
