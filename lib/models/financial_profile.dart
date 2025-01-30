import 'package:bondgrid/enums/annual_income.dart';
import 'package:bondgrid/enums/downturn_reaction.dart';
import 'package:bondgrid/enums/investment_horizon.dart';
import 'package:bondgrid/enums/investment_priority.dart';
import 'package:bondgrid/enums/net_worth.dart';

class FinancialProfile {
  InvestmentPriority? investmentPriority;
  InvestmentHorizon? investmentHorizon;
  DownturnRection? downturnReaction;
  AnnualIncome? annualIncome;
  NetWorth? netWorth;

  FinancialProfile();

  FinancialProfile.fromParams(this.investmentPriority, this.investmentHorizon,
      this.downturnReaction, this.annualIncome, this.netWorth);

  Map<String, dynamic> toJson() {
    return {
      'investmentPriority': investmentPriority?.value,
      'investmentHorizon': investmentHorizon?.value,
      'downturnReaction': downturnReaction?.value,
      'annualIncome': annualIncome?.value,
      'netWorth': netWorth?.value
    };
  }

  FinancialProfile.fromJson(Map<String, dynamic> json) {
    investmentPriority = json['investmentPriority'] != null
        ? InvestmentPriority.values
            .firstWhere((e) => e.value == json['investmentPriority'])
        : null;
    investmentHorizon = json['investmentHorizon'] != null
        ? InvestmentHorizon.values
            .firstWhere((e) => e.value == json['investmentHorizon'])
        : null;
    downturnReaction = json['downturnReaction'] != null
        ? DownturnRection.values
            .firstWhere((e) => e.value == json['downturnReaction'])
        : null;
    annualIncome = json['annualIncome'] != null
        ? AnnualIncome.values.firstWhere((e) => e.value == json['annualIncome'])
        : null;
    netWorth = json['netWorth'] != null
        ? NetWorth.values.firstWhere((e) => e.value == json['netWorth'])
        : null;
  }

  bool isComplete() {
    return [
      investmentPriority,
      investmentHorizon,
      downturnReaction,
      annualIncome,
      netWorth
    ].every((element) => element != null);
  }
}
