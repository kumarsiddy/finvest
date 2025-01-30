import 'package:bondgrid/models/holding.dart';

class HoldingList {
  List<Holding> holdings = [];

  HoldingList();
  HoldingList.empty();

  HoldingList.fromJson(Map<String, dynamic> json) {
    dynamic list = json['elements'];
    for (var element in list) {
      holdings.add(Holding.fromJson(element));
    }

    // Sort the holdings by maturity time in ascending order
    holdings.sort((a, b) {
      if (a.maturityDate == null && b.maturityDate == null) {
        return 0; // Both are null, treat them as equal
      }
      if (a.maturityDate == null) {
        return 1; // Treat null maturityDate in 'a' as later
      }
      if (b.maturityDate == null) {
        return -1; // Treat null maturityDate in 'b' as later
      }

      DateTime dateTimeA = DateTime.parse(a.maturityDate!);
      DateTime dateTimeB = DateTime.parse(b.maturityDate!);
      return dateTimeA.compareTo(dateTimeB);
    });
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> jsonList =
        holdings.map((holding) => holding.toJson()).toList();

    return {
      'elements': jsonList,
    };
  }
}
