// filepath: lib/data/models/dose_history.dart
class DoseHistory {
  final int? id;
  final int reminderId;
  final String medicineName;
  final String doseDetails;
  final String takenAt; // ISO 8601 format

  DoseHistory({
    this.id,
    required this.reminderId,
    required this.medicineName,
    required this.doseDetails,
    required this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'medicineName': medicineName,
      'doseDetails': doseDetails,
      'takenAt': takenAt,
    };
  }

  factory DoseHistory.fromMap(Map<String, dynamic> map) {
    return DoseHistory(
      id: map['id'],
      reminderId: map['reminderId'],
      medicineName: map['medicineName'],
      doseDetails: map['doseDetails'],
      takenAt: map['takenAt'],
    );
  }
}