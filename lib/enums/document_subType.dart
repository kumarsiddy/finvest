enum DocumentSubType {
  MONTHLY_STATEMENT("monthly_statement"),
  QUARTERLY_CONFIRMATION("quarterly_confirmation"),
  TRADE_CONFIRMATION("trade_confirmation"),
  COURTESY_INFORMATION("courtesy_information"),
  TAX_FORM_1099("tax_form_1099"),
  ACCOUNT_SUMMARY("account_summary");

  final String value;

  const DocumentSubType(this.value);
}
