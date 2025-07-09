class Reminder {
  final int? id;
  final String medicineName;
  final String time; // Store TimeOfDay as a string e.g., "HH:mm"
  final int doseCount;
  final String doseUnit;
  final String doseType;
  final String? timing; // e.g., "emptyStomach"
  final int duration;
  final String durationType;

  Reminder({
    this.id,
    required this.medicineName,
    required this.time,
    required this.doseCount,
    required this.doseUnit,
    required this.doseType,
    this.timing,
    required this.duration,
    required this.durationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineName': medicineName,
      'time': time,
      'doseCount': doseCount,
      'doseUnit': doseUnit,
      'doseType': doseType,
      'timing': timing,
      'duration': duration,
      'durationType': durationType,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      medicineName: map['medicineName'],
      time: map['time'],
      doseCount: map['doseCount'],
      doseUnit: map['doseUnit'],
      doseType: map['doseType'],
      timing: map['timing'],
      duration: map['duration'],
      durationType: map['durationType'],
    );
  }
}
