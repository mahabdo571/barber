import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String customerId;
  final String businessId;
  final String serviceId;
  final String timeSlotId;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending, confirmed, cancelled, completed
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.businessId,
    required this.serviceId,
    required this.timeSlotId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Booking copyWith({
    String? id,
    String? customerId,
    String? businessId,
    String? serviceId,
    String? timeSlotId,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      businessId: businessId ?? this.businessId,
      serviceId: serviceId ?? this.serviceId,
      timeSlotId: timeSlotId ?? this.timeSlotId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'businessId': businessId,
      'serviceId': serviceId,
      'timeSlotId': timeSlotId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'notes': notes ?? '-',
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String ,
      customerId: map['customerId'] as String,
      businessId: map['businessId'] as String,
      serviceId: map['serviceId'] as String,
      timeSlotId: map['timeSlotId'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      status: map['status'] as String ,
      notes: map['notes'] as String? ?? '-',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    businessId,
    serviceId,
    timeSlotId,
    startTime,
    endTime,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
}
