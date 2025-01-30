import 'package:bondgrid/enums/holding_status.dart';
import 'package:bondgrid/models/transaction_list.dart';

class Holding {
  String? id;
  String? assetSymbol;
  String? duration;
  double? purchaseAmount;
  String? maturityDate;
  double? maturityAmount;
  String? purchaseDate;
  HoldingStatus? status;
  double? currentValue;
  double? yieldToMaturity;
  double? numberShares;
  double? pendingSellShares;
  double? availableSellShares;
  double? averagePricePerShare;
  bool? autoRoll;
  TransactionList trades;

  Holding({
    this.id,
    this.assetSymbol,
    this.duration,
    this.purchaseAmount,
    this.maturityDate,
    this.maturityAmount,
    this.purchaseDate,
    this.status,
    this.currentValue,
    this.yieldToMaturity,
    this.numberShares,
    this.pendingSellShares,
    this.availableSellShares,
    this.averagePricePerShare,
    this.autoRoll,
    TransactionList? trades,
  }) : trades = trades ?? TransactionList.empty();

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'],
      assetSymbol: json['assetSymbol'],
      duration: json['duration'],
      purchaseAmount: _toDouble(json['purchaseAmount']),
      maturityDate: json['maturityDate'],
      maturityAmount: _toDouble(json['maturityAmount']),
      purchaseDate: json['createdAt'],
      status: json['status'] != null
          ? HoldingStatus.values.firstWhere((e) => e.value == json['status'])
          : null,
      currentValue: _toDouble(json['currentValue']),
      yieldToMaturity: _toDouble(json['yieldToMaturityFormatted']),
      numberShares: _toDouble(json['numberShares']),
      pendingSellShares: _toDouble(json['pendingSellShares']),
      availableSellShares: _toDouble(json['availableSellShares']),
      averagePricePerShare: _toDouble(json['averagePricePerShare']),
      autoRoll: json['autoRoll'],
      trades: json['trades'] != null
          ? TransactionList.fromJson({'elements': json['trades']})
          : null,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetSymbol': assetSymbol,
      'duration': duration,
      'purchaseAmount': purchaseAmount,
      'maturityDate': maturityDate,
      'maturityAmount': maturityAmount,
      'createdAt': purchaseDate,
      'status': status?.value,
      'currentValue': currentValue,
      'yieldToMaturityFormatted': yieldToMaturity,
      'numberShares': numberShares,
      'pendingSellShares': pendingSellShares,
      'availableSellShares': availableSellShares,
      'averagePricePerShare': averagePricePerShare,
      'autoRoll': autoRoll,
      'trades': trades.transactions.map((t) => t.toJson()).toList(),
    };
  }

  String getTradeSymbol() {
    bool hasPendingBuy = false;
    bool hasPendingSell = false;

    for (var trade in trades.transactions) {
      if (trade.getMappedStatus() == "Pending") {
        String actionLowercase = trade.action?.toLowerCase() ?? "";
        if (actionLowercase.contains("buy")) {
          hasPendingBuy = true;
        } else if (actionLowercase.contains("sell")) {
          hasPendingSell = true;
        }
      }
    }

    if (hasPendingBuy && hasPendingSell) {
      return "(+/-)  ";
    } else if (hasPendingBuy) {
      return "(+)  ";
    } else if (hasPendingSell) {
      return "(-)  ";
    } else {
      return "";
    }
  }
}
