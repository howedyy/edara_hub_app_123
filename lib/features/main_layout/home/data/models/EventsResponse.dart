import 'Data.dart';

class EventsResponse {
  EventsResponse({
     required this.success,
      required this.message,
      required this.data,});

  factory EventsResponse.fromJson(dynamic json) {
    return EventsResponse(success: json['success'], message: json['message'], data: Data.fromJson(json['data']));

  }
  bool success;
  String message;
  Data data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data.toJson();
    }
    return map;
  }

}