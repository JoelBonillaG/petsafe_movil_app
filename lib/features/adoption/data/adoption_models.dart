import 'dart:convert';

class AdoptionTag {
  const AdoptionTag({required this.id, required this.name});

  final int id;
  final String name;

  factory AdoptionTag.fromJson(Map<String, dynamic> json) {
    return AdoptionTag(
      id: _readInt(json['id']),
      name: _readString(json['name']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};
}

class AdoptionItem {
  const AdoptionItem({
    required this.id,
    required this.patientId,
    required this.petName,
    required this.speciesName,
    required this.breedName,
    required this.contactPhone,
    required this.contactName,
    required this.contactEmail,
    required this.story,
    required this.requirements,
    required this.imageUrl,
    required this.tags,
  });

  final int id;
  final int patientId;
  final String petName;
  final String? speciesName;
  final String? breedName;
  final String? contactPhone;
  final String? contactName;
  final String? contactEmail;
  final String? story;
  final String? requirements;
  final String? imageUrl;
  final List<AdoptionTag> tags;

  String get speciesLabel => speciesName?.trim().isNotEmpty == true ? speciesName! : 'Especie desconocida';
  String get breedLabel => breedName?.trim().isNotEmpty == true ? breedName! : 'Raza desconocida';

  List<String> get tagNames => tags.map((t) => t.name).toList(growable: false);

  factory AdoptionItem.fromJson(Map<String, dynamic> json) {
    final imageMap = json['image'];
    String? imageUrl;
    if (imageMap is Map) {
      imageUrl = _readNullableString(imageMap['url']);
    }

    return AdoptionItem(
      id: _readInt(json['id']),
      patientId: _readInt(json['patientId']),
      petName: _readString(json['petName']),
      speciesName: _readNullableString(json['speciesName']),
      breedName: _readNullableString(json['breedName']),
      contactPhone: _readNullableString(json['contactPhone']),
      contactName: _readNullableString(json['contactName']),
      contactEmail: _readNullableString(json['contactEmail']),
      story: _readNullableString(json['story']),
      requirements: _readNullableString(json['requirements']),
      imageUrl: imageUrl,
      tags: _readTagList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'patientId': patientId,
      'petName': petName,
      'speciesName': speciesName,
      'breedName': breedName,
      'contactPhone': contactPhone,
      'contactName': contactName,
      'contactEmail': contactEmail,
      'story': story,
      'requirements': requirements,
      'imageUrl': imageUrl,
      'tags': tags.map((t) => t.toJson()).toList(growable: false),
    };
  }
}

class AdoptionListResult {
  const AdoptionListResult({
    required this.items,
    required this.totalItems,
    required this.hasNextPage,
    this.fromCache = false,
  });

  final List<AdoptionItem> items;
  final int totalItems;
  final bool hasNextPage;
  final bool fromCache;

  factory AdoptionListResult.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final meta = json['meta'];

    final items = <AdoptionItem>[];
    if (dataList is List) {
      for (final item in dataList) {
        if (item is Map<String, dynamic>) {
          items.add(AdoptionItem.fromJson(item));
        } else if (item is Map) {
          items.add(AdoptionItem.fromJson(item.cast<String, dynamic>()));
        }
      }
    }

    int totalItems = 0;
    bool hasNextPage = false;
    if (meta is Map) {
      totalItems = _readInt(meta['totalItems']);
      hasNextPage = _readBool(meta['hasNextPage']);
    }

    return AdoptionListResult(
      items: items,
      totalItems: totalItems,
      hasNextPage: hasNextPage,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'data': items.map((i) => i.toJson()).toList(growable: false),
      'meta': <String, dynamic>{
        'totalItems': totalItems,
        'hasNextPage': hasNextPage,
      },
    };
  }

  AdoptionListResult copyWith({bool? fromCache}) {
    return AdoptionListResult(
      items: items,
      totalItems: totalItems,
      hasNextPage: hasNextPage,
      fromCache: fromCache ?? this.fromCache,
    );
  }
}

List<AdoptionTag> _readTagList(Object? value) {
  if (value is List) {
    return value.whereType<Map>().map((item) {
      final map = item is Map<String, dynamic> ? item : item.cast<String, dynamic>();
      return AdoptionTag.fromJson(map);
    }).toList(growable: false);
  }

  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return _readTagList(decoded);
      }
    } catch (_) {}
  }

  return const <AdoptionTag>[];
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _readString(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _readNullableString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

bool _readBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    if (value.trim().toLowerCase() == 'true') return true;
    if (value.trim().toLowerCase() == 'false') return false;
  }
  return fallback;
}
