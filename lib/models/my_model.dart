import 'dart:convert';

class MyModel {
  int? id;
  String resultDecision;
  List<String> decisionValue;

  MyModel({this.id, required this.resultDecision, required this.decisionValue});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resultDecision': resultDecision,
      'decisionValue': json.encode(decisionValue), // Simpan sebagai JSON string
    };
  }

  static MyModel fromMap(Map<String, dynamic> map) {
    return MyModel(
      id: map['id'],
      resultDecision: map['resultDecision'],
      decisionValue: List<String>.from(json.decode(map['decisionValue'])), // Kembali ke List
    );
  }
}
