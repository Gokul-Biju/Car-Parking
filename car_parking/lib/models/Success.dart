import 'package:cloud_firestore/cloud_firestore.dart';

class Success {
  final String name;
  final int space;
  final String slot;
  final Timestamp Start;
  final Timestamp end;
  final String vehicle;
  final String status;
  final String locationId;

  Success({
    required this.name,
    required this.space,
    required this.slot,
    required this.Start,
    required this.end,
    required this.vehicle,
    required this.status,
    required this.locationId
  });

  DateTime get dateTimeEnd => end.toDate();
  DateTime get dateTimeStart => Start.toDate();

  factory Success.fromJson(Map<String, dynamic> json) {
    return Success(
      name: json['name'] as String,
      space: json['space'] as int,
      slot: json['slot'] as String,
      Start: json['Start'] as Timestamp,
      end: json['end'] as Timestamp,
      vehicle: json['vehicle'] as String,
      status: json['status'] as String,
      locationId: json['locationId'] as String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'space': space,
      'slot': slot,
      'Start': Start,
      'end': end,
      'vehicle': vehicle,
      'status': status,
      'locationId' : locationId
    };
  }
}