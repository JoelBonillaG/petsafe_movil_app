class VaccinationPlanDose {
  const VaccinationPlanDose({
    required this.id,
    required this.doseLabel,
    required this.vaccineName,
    required this.status,
    this.scheduledDate,
    this.appliedDate,
  });

  final int id;
  final String doseLabel;
  final String vaccineName;
  final String status;
  final DateTime? scheduledDate;
  final DateTime? appliedDate;

  bool get isApplied => status.toUpperCase() == 'APPLIED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isOverdue => status.toUpperCase() == 'OVERDUE';
  bool get isSkipped => status.toUpperCase() == 'SKIPPED';

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'APPLIED':
        return 'Aplicada';
      case 'PENDING':
        return 'Pendiente';
      case 'OVERDUE':
        return 'Vencida';
      case 'SKIPPED':
        return 'Omitida';
      default:
        return status;
    }
  }

  factory VaccinationPlanDose.fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] ?? json['vaccineProduct'];
    String vaccineName = '';
    if (productMap is Map) {
      vaccineName = _readString(productMap['name'] ?? productMap['commercialName']);
    }
    if (vaccineName.isEmpty) {
      vaccineName = _readString(json['vaccineName'] ?? json['name']);
    }

    final doseLabel = _readString(
      json['doseLabel'] ?? json['dose'] ?? json['doseNumber'],
      fallback: 'Dosis',
    );

    return VaccinationPlanDose(
      id: _readInt(json['id']),
      doseLabel: doseLabel,
      vaccineName: vaccineName.isEmpty ? 'Vacuna' : vaccineName,
      status: _readString(json['status'], fallback: 'PENDING'),
      scheduledDate: _readDateTime(json['scheduledDate'] ?? json['dueDate']),
      appliedDate: _readDateTime(json['appliedDate'] ?? json['applicationDate']),
    );
  }
}

class VaccinationPlan {
  const VaccinationPlan({
    required this.patientId,
    required this.doses,
    this.schemeName,
  });

  final int patientId;
  final List<VaccinationPlanDose> doses;
  final String? schemeName;

  int get appliedCount => doses.where((d) => d.isApplied).length;
  int get pendingCount => doses.where((d) => d.isPending || d.isOverdue).length;
  int get totalCount => doses.length;

  factory VaccinationPlan.fromJson(Map<String, dynamic> json, {required int patientId}) {
    final dosesList = json['doses'] ?? json['planDoses'] ?? json['data'];
    final doses = <VaccinationPlanDose>[];
    if (dosesList is List) {
      for (final item in dosesList) {
        if (item is Map) {
          doses.add(VaccinationPlanDose.fromJson(
            item is Map<String, dynamic> ? item : item.cast<String, dynamic>(),
          ));
        }
      }
    }

    final schemeMap = json['scheme'] ?? json['vaccinationScheme'];
    String? schemeName;
    if (schemeMap is Map) {
      schemeName = _readNullableString(schemeMap['name']);
    }
    schemeName ??= _readNullableString(json['schemeName']);

    return VaccinationPlan(
      patientId: patientId,
      doses: doses,
      schemeName: schemeName,
    );
  }
}

class VaccinationApplication {
  const VaccinationApplication({
    required this.id,
    required this.vaccineName,
    required this.applicationDate,
    this.batchNumber,
    this.nextDoseDate,
    this.notes,
  });

  final int id;
  final String vaccineName;
  final DateTime applicationDate;
  final String? batchNumber;
  final DateTime? nextDoseDate;
  final String? notes;

  factory VaccinationApplication.fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] ?? json['vaccineProduct'];
    String vaccineName = '';
    if (productMap is Map) {
      vaccineName = _readString(productMap['name'] ?? productMap['commercialName']);
    }
    if (vaccineName.isEmpty) {
      vaccineName = _readString(json['vaccineName'] ?? json['name']);
    }

    return VaccinationApplication(
      id: _readInt(json['id']),
      vaccineName: vaccineName.isEmpty ? 'Vacuna' : vaccineName,
      applicationDate: _readDateTime(
        json['applicationDate'] ?? json['appliedDate'] ?? json['date'],
      ) ?? DateTime.now(),
      batchNumber: _readNullableString(json['batchNumber'] ?? json['batch']),
      nextDoseDate: _readDateTime(json['nextDoseDate'] ?? json['nextApplicationDate']),
      notes: _readNullableString(json['notes'] ?? json['observations']),
    );
  }
}

class VaccinationApplicationsResult {
  const VaccinationApplicationsResult({required this.applications});

  final List<VaccinationApplication> applications;

  factory VaccinationApplicationsResult.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] ?? json;
    final items = <VaccinationApplication>[];
    if (dataList is List) {
      for (final item in dataList) {
        if (item is Map) {
          items.add(VaccinationApplication.fromJson(
            item is Map<String, dynamic> ? item : item.cast<String, dynamic>(),
          ));
        }
      }
    }
    return VaccinationApplicationsResult(applications: items);
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
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return DateTime.tryParse(value.toString());
}
