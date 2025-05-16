import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  final String id;
  final String businessId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isBooked;
  final String? bookingId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimeSlot({
    required this.id,
    required this.businessId,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    this.bookingId,
    required this.createdAt,
    required this.updatedAt,
  });

  TimeSlot copyWith({
    String? id,
    String? businessId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isBooked,
    String? bookingId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBooked: isBooked ?? this.isBooked,
      bookingId: bookingId ?? this.bookingId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isBooked': isBooked,
      'bookingId': bookingId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'] as String,
      businessId: map['businessId'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      isBooked: map['isBooked'] as bool,
      bookingId: map['bookingId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    businessId,
    startTime,
    endTime,
    isBooked,
    bookingId,
    createdAt,
    updatedAt,
  ];
}
