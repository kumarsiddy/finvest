enum PaymentMethodStatus {
  DISCONNECTED("disconnected", "Disconnected"),
  PENDING("pending", "Active"),
  ACTIVE("active", "Active"),
  BLOCKED("blocked", "Blocked");

  final String value;
  final String displayValue;

  const PaymentMethodStatus(this.value, this.displayValue);
}
