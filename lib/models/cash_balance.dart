class CashBalance {
  String? portfolioValue;
  String? cashBalance;
  String? buyingPower;
  String? pendingWithdrawalAmount;
  String? pendingBuyOrderAmount;
  String? pendingDepositAmount;
  String? pendingSaleOrderAmount;
  String? cashInterestRate;
  String? feeAccruedAmount;
  String? withdrawableAmount;
  String? totalInterest;
  String? totalUnrealizedGains;
  String? cashInterestAccrued;
  String? totalRealizedGains;
  String? totalFees;
  String? totalBonus;

  CashBalance();

  CashBalance.fromParams(
      this.portfolioValue,
      this.cashBalance,
      this.buyingPower,
      this.pendingWithdrawalAmount,
      this.pendingBuyOrderAmount,
      this.pendingDepositAmount,
      this.pendingSaleOrderAmount,
      this.cashInterestRate,
      this.totalInterest,
      this.totalUnrealizedGains,
      this.cashInterestAccrued,
      this.totalRealizedGains,
      this.totalFees,
      this.totalBonus,
      this.withdrawableAmount,
      this.feeAccruedAmount);

  CashBalance.fromJson(Map<String, dynamic> json) {
    portfolioValue = json['portfolioValue'].toString();
    cashBalance = json['cashBalance'].toString();
    buyingPower = json['buyingPower'].toString();
    pendingWithdrawalAmount = json['pendingWithdrawalAmount'].toString();
    pendingBuyOrderAmount = json['pendingBuyOrderAmount'].toString();
    pendingDepositAmount = json['pendingDepositAmount'].toString();
    pendingSaleOrderAmount = json['pendingSaleOrderAmount'].toString();
    cashInterestRate = json['cashInterestRate'] ?? "4.4";
    totalInterest = json['totalInterest'].toString();
    totalUnrealizedGains = json['totalUnrealizedGains'].toString();
    cashInterestAccrued = json['cashInterestAccrued'].toString();
    totalRealizedGains = json['totalRealizedGains'].toString();
    totalFees = json['totalFees'].toString();
    totalBonus = json['totalBonus'].toString();
    feeAccruedAmount = json['feeAccruedAmount'].toString();
    withdrawableAmount = json['withdrawableAmount'].toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolioValue': portfolioValue,
      'cashBalance': cashBalance,
      'buyingPower': buyingPower,
      'pendingWithdrawalAmount': pendingWithdrawalAmount,
      'pendingBuyOrderAmount': pendingBuyOrderAmount,
      'pendingDepositAmount': pendingDepositAmount,
      'pendingSaleOrderAmount': pendingSaleOrderAmount,
      'cashInterestRate': cashInterestRate,
      'totalInterest': totalInterest,
      'totalUnrealizedGains': totalUnrealizedGains,
      'cashInterestAccrued': cashInterestAccrued,
      'totalRealizedGains': totalRealizedGains,
      'totalFees': totalFees,
      'totalBonus': totalBonus,
      'feeAccruedAmount': feeAccruedAmount,
      'withdrawableAmount': withdrawableAmount,
    };
  }
}
