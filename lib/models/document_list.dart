import 'package:bondgrid/models/document.dart';

class DocumentList {
  List<Document> documents = [];

  DocumentList();
  DocumentList.empty();

  DocumentList.fromJson(Map<String, dynamic> json) {
    dynamic list = json['elements'];
    for (var element in list) {
      documents.add(Document.fromJson(element));
    }
  }
}
