import 'package:equatable/equatable.dart';

/// Full category object returned by the categories API.
///
/// Maps to `CategoryDTO` from the backend.
class CategoryModel extends Equatable {
  const CategoryModel({
    required this.id,
    required this.name,
    this.color,
    this.icon,
    required this.isDefault,
    required this.position,
    required this.expenseCount,
  });

  final String id;
  final String name;

  /// Hex color string, e.g. "#16A34A". Null when the server sends no color.
  final String? color;

  /// Emoji icon character. Null when the server sends no icon.
  final String? icon;

  final bool isDefault;

  /// Zero-based display order; lower values appear first.
  final int position;

  final int expenseCount;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      position: json['position'] as int? ?? 0,
      expenseCount: json['expenseCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        'isDefault': isDefault,
        'position': position,
        'expenseCount': expenseCount,
      };

  CategoryModel copyWith({
    String? id,
    String? name,
    String? color,
    String? icon,
    bool? isDefault,
    int? position,
    int? expenseCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      position: position ?? this.position,
      expenseCount: expenseCount ?? this.expenseCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, color, icon, isDefault, position, expenseCount];
}

/// Lightweight category reference embedded inside `ExpenseDTO`.
///
/// Matches the nested `category` object returned in expense responses.
class CategorySummary extends Equatable {
  const CategorySummary({
    required this.id,
    required this.name,
    this.color,
    this.icon,
  });

  final String id;
  final String name;
  final String? color;
  final String? icon;

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
      };

  @override
  List<Object?> get props => [id, name, color, icon];
}
