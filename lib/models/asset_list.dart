import 'package:bondgrid/models/asset.dart';

class AssetList {
  List<Asset> assets = [];

  AssetList();
  AssetList.empty();

  AssetList.fromJson(Map<String, dynamic> json) {
    dynamic list = json['elements'];
    for (var element in list) {
      assets.add(Asset.fromJson(element));
    }

    assets.sort((a, b) {
      DateTime dateTimeA = DateTime.parse(a.maturityDate!);
      DateTime dateTimeB = DateTime.parse(b.maturityDate!);
      return dateTimeA.compareTo(dateTimeB);
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'elements': assets.map((asset) => asset.toJson()).toList(),
    };
  }
}
