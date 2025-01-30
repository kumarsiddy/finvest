enum ResidenceStatus {
  CITIZEN("CITIZEN", "Citizen"),
  RESIDENT("RESIDENT", "Resident"),
  NON_RESIDENT("NON_RESIDENT", "Non-Resident");

  final String value;
  final String displayValue;

  const ResidenceStatus(this.value, this.displayValue);
}
