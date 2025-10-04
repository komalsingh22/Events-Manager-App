import 'package:campus/models/user.dart';
import 'package:campus/models/event.dart';

enum RegistrationStatus { confirmed, cancelled, waitlisted }

class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final Event? event;
  final User? user;
  final DateTime registeredAt;
  final RegistrationStatus status;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    this.event,
    this.user,
    required this.registeredAt,
    this.status = RegistrationStatus.confirmed,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'].toString(),
      eventId: json['event_id'].toString(),
      userId: json['user_id'].toString(),
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      registeredAt: DateTime.parse(json['registered_at']),
      status: RegistrationStatus.values.firstWhere(
        (s) => s.name == (json['status'] ?? 'confirmed'),
        orElse: () => RegistrationStatus.confirmed,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'user_id': userId,
      'event': event?.toJson(),
      'user': user?.toJson(),
      'registered_at': registeredAt.toIso8601String(),
      'status': status.name,
    };
  }

  EventRegistration copyWith({
    String? id,
    String? eventId,
    String? userId,
    Event? event,
    User? user,
    DateTime? registeredAt,
    RegistrationStatus? status,
  }) {
    return EventRegistration(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      event: event ?? this.event,
      user: user ?? this.user,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
    );
  }
}
