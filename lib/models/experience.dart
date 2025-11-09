import 'package:equatable/equatable.dart';

class Experience extends Equatable {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;

  const Experience({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      tagline: json['tagline'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      iconUrl: json['icon_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'image_url': imageUrl,
      'icon_url': iconUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, tagline, description, imageUrl, iconUrl];
}

class ExperiencesResponse extends Equatable {
  final String message;
  final List<Experience> experiences;

  const ExperiencesResponse({
    required this.message,
    required this.experiences,
  });

  factory ExperiencesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final experiencesList = data['experiences'] as List<dynamic>? ?? [];
    
    return ExperiencesResponse(
      message: json['message'] ?? '',
      experiences: experiencesList
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [message, experiences];
}