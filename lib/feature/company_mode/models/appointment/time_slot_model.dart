class TimeSlotModel {
  final String time;
  final bool isActive;
  final String createdBy;

  TimeSlotModel({
    required this.time,
    required this.isActive,
    required this.createdBy,
  });

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) => TimeSlotModel(
    time: map['time'],
    isActive: map['isActive'],
    createdBy: map['createdBy'],
  );

  Map<String, dynamic> toMap() => {
    'time': time,
    'isActive': isActive,
    'createdBy': createdBy,
  };
}
