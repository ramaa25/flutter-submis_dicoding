
class MyModel {
  int? id;
  String resultDecision;
  List<String> decisionValue;

  MyModel({this.id, required this.resultDecision, required this.decisionValue});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'resultDecision': resultDecision,
      // `decisionValue` is handled separately in decision_value_table
    };
  }

// Suggested code may be subject to a license. Learn more: ~LicenseLog:1528714582.
  static MyModel fromMap(Map<String, dynamic> map, List<String> decisionValues) {
    return MyModel(
      id: map['id'],
      resultDecision: map['resultDecision'] ?? '',
      decisionValue: decisionValues, // Kembali ke List
    );
  }
}
