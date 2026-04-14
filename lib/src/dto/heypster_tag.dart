import 'package:meta/meta.dart';

/// A search tag from the heypster API.
@immutable
class HeypsterTag {
  /// The unique identifier.
  final int id;

  /// The raw tag string (may contain dashes).
  final String tag;

  /// Creates a [HeypsterTag] instance.
  const HeypsterTag({required this.id, required this.tag});

  /// The display-friendly name with dashes replaced by spaces.
  String get formatted => tag.replaceAll('-', ' ');

  /// Creates a [HeypsterTag] from an API JSON response.
  factory HeypsterTag.fromJson(Map<String, dynamic> json) {
    return HeypsterTag(id: json['id'] as int, tag: json['tag'] as String);
  }

  /// Converts this tag to a JSON map.
  Map<String, dynamic> toJson() => {'id': id, 'tag': tag};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeypsterTag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tag == other.tag;

  @override
  int get hashCode => Object.hash(id, tag);
}
