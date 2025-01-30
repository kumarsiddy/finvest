class Document {
  String? id;
  String? type;
  String? subType;
  String? name;
  String? date;

  Document();

  Document.fromParams(this.id, this.type, this.subType, this.name, this.date);

  Document.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    subType = json['subType'];
    name = json['name'];
    date = json['date'];
  }
}
