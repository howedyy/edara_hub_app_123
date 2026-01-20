import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';

class EventModel {
  int? id;
  String? title;
  String? description;
  String? startDate;
  String? endDate;
  String? image;
  String? location;

  EventModel({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.image,
    this.location,
  });

  EventModel.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    image = json['image'];
    location = json['location'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['description'] = description;
    map['start_date'] = startDate;
    map['end_date'] = endDate;
    map['image'] = image;
    map['location'] = location;
    return map;
  }

  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      image: image,
      location: location,
    );
  }
}
