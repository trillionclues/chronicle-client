import 'package:json_annotation/json_annotation.dart';

part 'participant_model.g.dart';

@JsonSerializable()
class ParticipantModel{
  final String id;
  final String name;
  final String photoUrl;
  final String? text;
  final bool isCreator;
  final bool hasSubmitted;
 final bool writingComplete;

  const ParticipantModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.text,
    this.isCreator = false,
    this.hasSubmitted = false,
    required this.writingComplete,
  });


  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
  _$ParticipantModelFromJson(json);

  Map<String, dynamic> json() => _$ParticipantModelToJson(this);
}