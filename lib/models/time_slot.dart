import 'package:equatable/equatable.dart';


/// Model يمثل TimeSlot واحد داخل اليوم
class TimeSlot extends Equatable {
  final String id;
  final String time; // بصيغة 'HH:mm'
  final bool available;
  final String? bookingId;

  const TimeSlot({
    required this.id,
    required this.time,
    this.available = true,
    this.bookingId,
  });

  /// إنشاء نسخة معدلة
  TimeSlot copyWith({
    String? id,
    String? time,
    bool? available,
    String? bookingId,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      time: time ?? this.time,
      available: available ?? this.available,
      bookingId: bookingId ?? this.bookingId,
    );
  }

  /// من JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json, String id) {
    return TimeSlot(
      id: id,
      time: json['time'] as String,
      available: json['available'] as bool? ?? true,
      bookingId: json['bookingId'] as String?,
    );
  }

  /// إلى JSON
  Map<String, dynamic> toJson() => {
        'time': time,
        'available': available,
        'bookingId': bookingId,
      };

  @override
  List<Object?> get props => [id, time, available, bookingId];
}