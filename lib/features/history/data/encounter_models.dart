class EncounterTreatment {
  const EncounterTreatment({
    required this.id,
    required this.name,
    required this.status,
    this.startDate,
  });

  final int id;
  final String name;
  final String status;
  final DateTime? startDate;

  factory EncounterTreatment.fromJson(Map<String, dynamic> json) {
    return EncounterTreatment(
      id: _readInt(json['id']),
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      startDate: _readDateTime(json['startDate']),
    );
  }
}

class EncounterVaccination {
  const EncounterVaccination({
    required this.id,
    this.vaccineName,
    this.batchNumber,
  });

  final int id;
  final String? vaccineName;
  final String? batchNumber;

  factory EncounterVaccination.fromJson(Map<String, dynamic> json) {
    return EncounterVaccination(
      id: _readInt(json['id']),
      vaccineName: json['vaccineName']?.toString(),
      batchNumber: json['batchNumber']?.toString(),
    );
  }
}

class ClientEncounter {
  const ClientEncounter({
    required this.id,
    required this.startTime,
    required this.status,
    this.endTime,
    this.generalNotes,
    this.vetName,
    this.consultationReason,
    required this.treatmentsCount,
    required this.vaccinationsCount,
    required this.dewormingsCount,
    required this.treatments,
    required this.vaccinations,
  });

  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final String? generalNotes;
  final String? vetName;
  final String? consultationReason;
  final int treatmentsCount;
  final int vaccinationsCount;
  final int dewormingsCount;
  final List<EncounterTreatment> treatments;
  final List<EncounterVaccination> vaccinations;

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'ABIERTA': return 'En curso';
      case 'CERRADA': return 'Completada';
      case 'CANCELADA': return 'Cancelada';
      default: return status;
    }
  }

  factory ClientEncounter.fromJson(Map<String, dynamic> json) {
    return ClientEncounter(
      id: _readInt(json['id']),
      startTime: _readDateTime(json['startTime']) ?? DateTime.now(),
      endTime: _readDateTime(json['endTime']),
      status: json['status']?.toString() ?? '',
      generalNotes: json['generalNotes']?.toString(),
      vetName: json['vetName']?.toString(),
      consultationReason: json['consultationReason']?.toString(),
      treatmentsCount: _readInt(json['treatmentsCount']),
      vaccinationsCount: _readInt(json['vaccinationsCount']),
      dewormingsCount: _readInt(json['dewormingsCount']),
      treatments: _readList(json['treatments'], EncounterTreatment.fromJson),
      vaccinations: _readList(json['vaccinations'], EncounterVaccination.fromJson),
    );
  }
}

class ClientHistoryResult {
  const ClientHistoryResult({required this.encounters});
  final List<ClientEncounter> encounters;

  factory ClientHistoryResult.fromJson(Map<String, dynamic> json) {
    return ClientHistoryResult(
      encounters: _readList(json['encounters'], ClientEncounter.fromJson),
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

int _readInt(Object? v, {int fallback = 0}) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v?.toString() ?? '') ?? fallback;
}

DateTime? _readDateTime(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v.trim());
  return null;
}

List<T> _readList<T>(Object? v, T Function(Map<String, dynamic>) parser) {
  if (v is! List) return [];
  return v.whereType<Map>().map((e) {
    final map = e is Map<String, dynamic> ? e : e.cast<String, dynamic>();
    return parser(map);
  }).toList();
}
