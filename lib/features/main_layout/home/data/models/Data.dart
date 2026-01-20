import 'EventModel.dart';

class Data {
  Data({
      required this.events,});

  factory Data.fromJson(dynamic json) {
    List<EventModel> events = [];
    if (json is List) {
      events = json.map((v) => EventModel.fromJson(v)).toList();
    } else if (json is Map && json['events'] != null) {
      events = (json['events'] as List).map((v) => EventModel.fromJson(v)).toList();
    }
    return Data(events: events);
  }

  List<EventModel> events;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (events != null) {
      map['events'] = events.map((v) => v.toJson()).toList();
    }
    return map;
  }

}