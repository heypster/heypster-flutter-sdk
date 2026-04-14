import 'package:meta/meta.dart';

/// A curated badge/category from the heypster API.
@immutable
class HeypsterBadge {
  /// The unique identifier.
  final int id;

  /// The display title.
  final String title;

  /// The relative path to the badge image.
  final String imagePath;

  /// Creates a [HeypsterBadge] instance.
  const HeypsterBadge({
    required this.id,
    required this.title,
    required this.imagePath,
  });

  /// The full URL for the badge image.
  Uri? get imageUrl {
    if (imagePath.isEmpty) return null;
    return Uri.parse('https://heypster-gif.com/$imagePath');
  }

  /// Creates a [HeypsterBadge] from an API JSON response.
  factory HeypsterBadge.fromJson(Map<String, dynamic> json) {
    return HeypsterBadge(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      imagePath: json['image_path'] as String? ?? '',
    );
  }

  /// Converts this badge to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'image_path': imagePath,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeypsterBadge &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
