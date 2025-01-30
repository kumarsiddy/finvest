import 'package:bondgrid/models/transaction.dart';

class TransactionList {
  List<Transaction> transactions = [];

  TransactionList();
  TransactionList.empty();

  TransactionList.fromJson(Map<String, dynamic> json) {
    dynamic list = json['elements'];
    for (var element in list) {
      transactions.add(Transaction.fromJson(element));
    }

    // Sort the transactions by time in descending order
    transactions.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a.createdTime!);
      DateTime dateTimeB = DateTime.parse(b.createdTime!);
      return dateTimeB.compareTo(dateTimeA);
    });
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonList =
        transactions.map((transaction) => transaction.toJson()).toList();

    return {
      'elements': jsonList,
    };
  }
}
