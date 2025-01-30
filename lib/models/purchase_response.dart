import 'package:bondgrid/models/transaction.dart';

class PurchaseResponse {
  String? tradeId;
  String? holdingId;
  Transaction? transaction;

  PurchaseResponse();

  PurchaseResponse.fromParams(this.tradeId, this.holdingId, this.transaction);

  PurchaseResponse.fromJson(Map<String, dynamic> json) {
    tradeId = json['tradeId'];
    holdingId = json['holdingId'];
    if (json.containsKey('transaction')) {
      transaction = Transaction.fromJson(json['transaction']);
    }
  }
}
