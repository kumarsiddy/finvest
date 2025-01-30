import 'package:bondgrid/enums/transaction_direction.dart';
import 'package:bondgrid/models/holding.dart';

class Transaction {
  String? action;
  String? duration;
  String? displayName;
  TransactionDirection? direction;
  String? orderType;
  String? amount;
  String? status;
  String? createdTime;
  String? lastUpdatedTime;
  String? executionDate;
  String? from;
  String? to;
  String? executionPrice;
  String? totalExecutionPrice;
  double? yieldToMaturity;
  Holding? holdingDetails;

  String? failureReason;

  // For maturity accrual events
  String? assetSymbol;
  String? maturityDate;
  String? assetDuration;

  Transaction(
      {this.action,
      this.duration,
      this.direction,
      this.displayName,
      this.orderType,
      this.amount,
      this.status,
      this.createdTime,
      this.lastUpdatedTime,
      this.executionDate,
      this.from,
      this.to,
      this.executionPrice,
      this.totalExecutionPrice,
      this.yieldToMaturity,
      this.holdingDetails,
      this.assetSymbol,
      this.maturityDate,
      this.assetDuration,
      this.failureReason});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final action = json['action'];
    final duration = json['duration'];
    // final displayName = duration != null ? '$action $duration' : action;
    return Transaction(
        action: action,
        duration: duration,
        displayName: json['displayName'],
        direction: json['direction'] != null
            ? TransactionDirection.values
                .firstWhere((e) => e.value == json['direction'])
            : null,
        orderType: json['orderType'],
        amount: json['amount']?.toString(),
        status: json['status'],
        createdTime: json['time'],
        lastUpdatedTime: json['lastUpdatedTime'],
        executionDate: json['executionDate'],
        from: json['from'],
        to: json['to'],
        executionPrice: json['executionPrice']?.toString(),
        totalExecutionPrice: json['totalExecutionPrice']?.toString(),
        yieldToMaturity: _toDouble(json['yieldToMaturityFormatted']),
        holdingDetails: json['portfolioHoldingDetails'] != null
            ? Holding.fromJson(json['portfolioHoldingDetails'])
            : null,
        assetSymbol: json['asset'],
        maturityDate: json['maturityDate'],
        assetDuration: json['assetName'],
        failureReason: json['failureReason']);
  }

  String getMappedStatus() {
    const statusMappings = {
      'Queued': 'Pending',
      'Initiated': 'Pending',
    };

    return statusMappings[status] ?? status ?? '';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, String> getMappedImage() {
    const statusMappings = {
      'Deposit': {
        'path': 'lib/assets/deposit.svg',
        'type': 'svg',
      },
      'Withdrawal': {
        'path': 'lib/assets/withdraw.svg',
        'type': 'svg',
      },
      'Buy': {
        'path': 'lib/assets/seal.png',
        'type': 'png',
      },
      'Sell': {
        'path': 'lib/assets/seal.png',
        'type': 'png',
      },
      'Treasury Bill Maturity': {
        'path': 'lib/assets/seal.png',
        'type': 'png',
      },
      'Fee': {
        'path': 'lib/assets/withdraw.svg',
        'type': 'svg',
      },
      'Tax': {
        'path': 'lib/assets/withdraw.svg',
        'type': 'svg',
      },
      'Cash Interest': {
        'path': 'lib/assets/interest.svg',
        'type': 'svg',
      },
    };

    if (action != null) {
      // Split the action into words
      List<String> words = action!.split(' ');

      // Search for a key that matches any of the words
      for (String word in words) {
        if (statusMappings.containsKey(word)) {
          return statusMappings[word]!;
        }
      }
    }

    // Default value if no match is found
    return {
      'path': 'lib/assets/interest.svg',
      'type': 'svg',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'duration': duration,
      'displayName': displayName,
      'direction': direction?.value,
      'orderType': orderType,
      'amount': amount,
      'status': status,
      'time': createdTime,
      'lastUpdatedTime': lastUpdatedTime,
      'executionDate': executionDate,
      'from': from,
      'to': to,
      'executionPrice': executionPrice,
      'totalExecutionPrice': totalExecutionPrice,
      'yieldToMaturityFormatted': yieldToMaturity,
      'portfolioHoldingDetails':
          holdingDetails?.toJson(), // Convert Holding to JSON
      'asset': assetSymbol,
      'maturityDate': maturityDate,
      'assetName': assetDuration,
      'failureReason': failureReason,
    };
  }
}
