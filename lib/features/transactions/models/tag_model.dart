import 'package:equatable/equatable.dart';

/// A user-defined label that can be attached to one or more transactions.
class TagModel extends Equatable {
  const TagModel({
    required this.id,
    required this.name,
    this.color,
  });

  final String id;
  final String name;

  /// Hex color string, e.g. "#4CAF50". Null means the UI uses a neutral
  /// default chip style.
  final String? color;

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (color != null) 'color': color,
      };

  TagModel copyWith({
    String? id,
    String? name,
    String? color,
    bool clearColor = false,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: clearColor ? null : (color ?? this.color),
    );
  }

  @override
  List<Object?> get props => [id, name, color];
}
