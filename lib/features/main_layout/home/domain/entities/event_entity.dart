import 'package:equatable/equatable.dart';

class EventEntity extends Equatable{
  final int? id;
  final String? title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? image;
  final String? location;

  const EventEntity({
    this.id,
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.image,
    this.location,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDate,
    endDate,
    image,
    location,
  ];
}
