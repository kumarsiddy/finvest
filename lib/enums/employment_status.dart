enum EmploymentStatus {
  EMPLOYED("EMPLOYED", "Employed"),
  SELF_EMPLOYED("SELF_EMPLOYED", "Self-Employed"),
  UNEMPLOYED("UNEMPLOYED", "Unemployed"),
  RETIRED("RETIRED", "Retired");

  final String value;
  final String displayValue;

  const EmploymentStatus(this.value, this.displayValue);
}
