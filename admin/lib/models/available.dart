import 'package:admin/models/slotime.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Available {
  bool? isAvailable;
  List<Slotime>? slotime;

  Available({this.isAvailable, this.slotime});

  Map<String, dynamic> toJson() {
    return {
      if (slotime != null) "slotime": slotime!.map((slot) => slot.toJson()).toList(),
    };
  }

  factory Available.fromJson(Map<String, dynamic> json) {
    List<Slotime>? slotimeList;
    bool? calculatedIsAvailable;

    if (json["slotime"] != null) {
      slotimeList = (json["slotime"] as List).map((item) => Slotime.fromJson(item)).toList();
      calculatedIsAvailable = true;
      for (int i = 0; i < slotimeList.length; i++) {
        Slotime slotime = slotimeList[i];
        if (slotime.startTime != null && slotime.endTime != null) { 
          Timestamp time = Timestamp.fromDate(DateTime.now());
          if (slotime.startTime!.compareTo(time) < 0 && slotime.endTime!.compareTo(time) > 0) {
            calculatedIsAvailable = false;
            break;
          }
        } else {
            calculatedIsAvailable = true;
            break;
        }
        print(calculatedIsAvailable);
      }
    }else{
      calculatedIsAvailable = true;
    }

    return Available(
      slotime: slotimeList,
      isAvailable: calculatedIsAvailable,
    );
  }

  bool get isAvailableNonNull {
    return isAvailable ?? false;
  }
}