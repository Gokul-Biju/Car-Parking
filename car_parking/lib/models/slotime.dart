import 'package:cloud_firestore/cloud_firestore.dart';

class Slotime {
  Timestamp? startTime; 
  Timestamp? endTime;   

  Slotime({this.startTime, this.endTime});

  Map<String, dynamic> toJson() {
    return {
      if (startTime != null) "startTime": startTime,
      if (endTime != null) "endTime": endTime,
    };
  }

  factory Slotime.fromJson(Map<String, dynamic> json) {
    return Slotime(
      startTime: json["startTime"] as Timestamp?, 
      endTime: json["endTime"] as Timestamp?,  
    );
  }
}