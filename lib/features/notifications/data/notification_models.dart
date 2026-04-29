class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.referenceType,
    this.referenceId,
    this.readAt,
  });

  final int id;
  final int userId;
  final String title;
  final String body;
  final String? referenceType;
  final int? referenceId;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _readInt(json['id']),
      userId: _readInt(json['userId']),
      title: _readString(json['title']),
      body: _readString(json['body']),
      referenceType: _readNullableString(json['referenceType']),
      referenceId: json['referenceId'] is int ? json['referenceId'] as int : null,
      readAt: _readDateTime(json['readAt']),
      createdAt: _readDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class UnreadCountResult {
  const UnreadCountResult({required this.count});
  final int count;
  factory UnreadCountResult.fromJson(Map<String, dynamic> json) {
    return UnreadCountResult(count: _readInt(json['count']));
  }
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

DateTime? _readDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) {
    final text = value.trim();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
  return null;
}
