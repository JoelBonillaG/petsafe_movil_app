import 'dart:convert';

class PetsListQuery {
  const PetsListQuery({
    required this.page,
    required this.limit,
    this.search,
  });

  final int page;
  final int limit;
  final String? search;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search!.trim().isNotEmpty) 'search': search!.trim(),
    };
  }

  String get normalizedSearch {
    return search?.trim().toLowerCase() ?? '';
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.totalItems,
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  final int totalItems;
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalItems: _readInt(json['totalItems']),
      itemCount: _readInt(json['itemCount']),
      itemsPerPage: _readInt(json['itemsPerPage']),
      totalPages: _readInt(json['totalPages']),
      currentPage: _readInt(json['currentPage']),
      hasNextPage: _readBool(json['hasNextPage']),
      hasPrevPage: _readBool(json['hasPrevPage']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'totalItems': totalItems,
      'itemCount': itemCount,
      'itemsPerPage': itemsPerPage,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}

class PetCatalogItem {
  const PetCatalogItem({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory PetCatalogItem.fromJson(Map<String, dynamic> json) {
    return PetCatalogItem(
      id: _readInt(json['id']),
      name: _readString(json['name']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }
}

class PetCondition {
  const PetCondition({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.active,
  });

  final int id;
  final String type;
  final String name;
  final String? description;
  final bool active;

  factory PetCondition.fromJson(Map<String, dynamic> json) {
    return PetCondition(
      id: _readInt(json['id']),
      type: _readString(json['type']),
      name: _readString(json['name']),
      description: _readNullableString(json['description']),
      active: _readBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'name': name,
      'description': description,
      'active': active,
    };
  }
}

class PetProfile {
  const PetProfile({
    required this.id,
    required this.code,
    required this.name,
    required this.sex,
    required this.birthDate,
    required this.currentWeight,
    required this.sterilized,
    required this.microchipCode,
    required this.distinguishingMarks,
    required this.generalAllergies,
    required this.generalHistory,
    required this.species,
    required this.breed,
    required this.color,
    required this.conditions,
  });

  final int id;
  final String code;
  final String name;
  final String sex;
  final DateTime? birthDate;
  final double? currentWeight;
  final bool sterilized;
  final String? microchipCode;
  final String? distinguishingMarks;
  final String? generalAllergies;
  final String? generalHistory;
  final PetCatalogItem? species;
  final PetCatalogItem? breed;
  final PetCatalogItem? color;
  final List<PetCondition> conditions;

  String get codeLabel => code.trim().isNotEmpty ? code.trim() : 'Sin codigo';

  String get speciesLabel => species?.name.trim().isNotEmpty == true ? species!.name.trim() : 'Sin especie';

  String get breedLabel => breed?.name.trim().isNotEmpty == true ? breed!.name.trim() : 'Sin raza';

  String get colorLabel => color?.name.trim().isNotEmpty == true ? color!.name.trim() : 'Sin color';

  String get microchipLabel {
    final value = microchipCode?.trim() ?? '';
    return value.isEmpty ? 'Sin microchip' : value;
  }

  String get sexLabel {
    switch (sex.trim().toUpperCase()) {
      case 'MACHO':
        return 'Macho';
      case 'HEMBRA':
        return 'Hembra';
      default:
        return 'No especificado';
    }
  }

  String get weightLabel {
    final value = currentWeight;
    if (value == null) {
      return 'Peso no registrado';
    }

    return '${value.toStringAsFixed(2)} kg';
  }

  String get ageLabel {
    final years = ageYears;
    if (years == null) {
      return 'Edad no registrada';
    }

    return '$years ${years == 1 ? 'ano' : 'anos'}';
  }

  int? get ageYears {
    final date = birthDate;
    if (date == null) {
      return null;
    }

    final now = DateTime.now();
    var years = now.year - date.year;
    final monthDiff = now.month - date.month;
    if (monthDiff < 0 || (monthDiff == 0 && now.day < date.day)) {
      years -= 1;
    }

    return years < 0 ? null : years;
  }

  factory PetProfile.fromJson(Map<String, dynamic> json) {
    return PetProfile(
      id: _readInt(json['id']),
      code: _readString(json['code']),
      name: _readString(json['name']),
      sex: _readString(json['sex']),
      birthDate: _readDateTime(json['birthDate']),
      currentWeight: _readDouble(json['currentWeight']),
      sterilized: _readBool(json['sterilized']),
      microchipCode: _readNullableString(json['microchipCode']),
      distinguishingMarks: _readNullableString(json['distinguishingMarks']),
      generalAllergies: _readNullableString(json['generalAllergies']),
      generalHistory: _readNullableString(json['generalHistory']),
      species: _readNested(json['species'], PetCatalogItem.fromJson),
      breed: _readNested(json['breed'], PetCatalogItem.fromJson),
      color: _readNested(json['color'], PetCatalogItem.fromJson),
      conditions: _readNestedList(json['conditions'], PetCondition.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'code': code,
      'name': name,
      'sex': sex,
      'birthDate': birthDate?.toIso8601String(),
      'currentWeight': currentWeight,
      'sterilized': sterilized,
      'microchipCode': microchipCode,
      'distinguishingMarks': distinguishingMarks,
      'generalAllergies': generalAllergies,
      'generalHistory': generalHistory,
      'species': species?.toJson(),
      'breed': breed?.toJson(),
      'color': color?.toJson(),
      'conditions': conditions.map((condition) => condition.toJson()).toList(growable: false),
    };
  }
}

class PetsListResult {
  const PetsListResult({
    required this.pets,
    required this.meta,
    this.fromCache = false,
    this.isOffline = false,
  });

  final List<PetProfile> pets;
  final PaginationMeta meta;
  final bool fromCache;
  final bool isOffline;

  factory PetsListResult.fromJson(Map<String, dynamic> json) {
    return PetsListResult(
      pets: _readNestedList(json['data'], PetProfile.fromJson),
      meta: PaginationMeta.fromJson(_readMap(json['meta'])),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': pets.map((pet) => pet.toJson()).toList(growable: false),
      'meta': meta.toJson(),
    };
  }

  PetsListResult copyWith({
    List<PetProfile>? pets,
    PaginationMeta? meta,
    bool? fromCache,
    bool? isOffline,
  }) {
    return PetsListResult(
      pets: pets ?? this.pets,
      meta: meta ?? this.meta,
      fromCache: fromCache ?? this.fromCache,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

Map<String, dynamic> _readMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.cast<String, dynamic>();
  }

  return <String, dynamic>{};
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double? _readDouble(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value.toString());
}

String _readString(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _readDateTime(Object? value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }

  return DateTime.tryParse(value.toString());
}

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value != 0;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
  }

  return fallback;
}

T? _readNested<T>(Object? value, T Function(Map<String, dynamic>) parser) {
  if (value is Map<String, dynamic>) {
    return parser(value);
  }

  if (value is Map) {
    return parser(value.cast<String, dynamic>());
  }

  return null;
}

List<T> _readNestedList<T>(Object? value, T Function(Map<String, dynamic>) parser) {
  if (value is List) {
    return value
        .whereType<Object?>()
        .map((item) => _readNested(item, parser))
        .whereType<T>()
        .toList(growable: false);
  }

  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is List) {
      return decoded
          .whereType<Object?>()
          .map((item) => _readNested(item, parser))
          .whereType<T>()
          .toList(growable: false);
    }
  }

  return <T>[];
}
