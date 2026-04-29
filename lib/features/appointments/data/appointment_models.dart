import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum AppointmentRequestStatus {
  pendiente,
  confirmada,
  rechazada,
  cancelada;

  String get label {
    switch (this) {
      case AppointmentRequestStatus.pendiente:
        return 'Pendiente';
      case AppointmentRequestStatus.confirmada:
        return 'Confirmada';
      case AppointmentRequestStatus.rechazada:
        return 'Rechazada';
      case AppointmentRequestStatus.cancelada:
        return 'Cancelada';
    }
  }

  Color get color {
    switch (this) {
      case AppointmentRequestStatus.pendiente:
        return AppColors.warning;
      case AppointmentRequestStatus.confirmada:
        return AppColors.success;
      case AppointmentRequestStatus.rechazada:
        return AppColors.error;
      case AppointmentRequestStatus.cancelada:
        return AppColors.textSecondary;
    }
  }

  static AppointmentRequestStatus fromString(String? value) {
    switch ((value ?? '').toUpperCase()) {
      case 'CONFIRMADA':
        return AppointmentRequestStatus.confirmada;
      case 'RECHAZADA':
        return AppointmentRequestStatus.rechazada;
      case 'CANCELADA':
        return AppointmentRequestStatus.cancelada;
      default:
        return AppointmentRequestStatus.pendiente;
    }
  }
}

class AppointmentRequest {
  const AppointmentRequest({
    required this.id,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.patientId,
    this.patientName,
    this.preferredDate,
    this.preferredTime,
    this.staffNotes,
  });

  final int id;
  final int? patientId;
  final String? patientName;
  final String reason;
  final String? preferredDate;
  final String? preferredTime;
  final AppointmentRequestStatus status;
  final String? staffNotes;
  final DateTime createdAt;

  factory AppointmentRequest.fromJson(Map<String, dynamic> json) {
    final patientRaw = json['patient'];
    String? patientName;
    int? patientId;
    if (patientRaw is Map) {
      patientName = patientRaw['name']?.toString();
      patientId = patientRaw['id'] is int ? patientRaw['id'] as int : int.tryParse(patientRaw['id']?.toString() ?? '');
    }

    return AppointmentRequest(
      id: _readInt(json['id']),
      patientId: patientId ?? _readNullableInt(json['patientId']),
      patientName: patientName,
      reason: json['reason']?.toString() ?? '',
      preferredDate: json['preferredDate']?.toString(),
      preferredTime: json['preferredTime']?.toString(),
      status: AppointmentRequestStatus.fromString(json['status']?.toString()),
      staffNotes: json['staffNotes']?.toString(),
      createdAt: _readDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class CreateAppointmentRequestPayload {
  const CreateAppointmentRequestPayload({
    required this.reason,
    this.patientId,
    this.preferredDate,
    this.preferredTime,
  });

  final String reason;
  final int? patientId;
  final String? preferredDate;
  final String? preferredTime;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reason': reason,
      if (patientId != null) 'patientId': patientId,
      if (preferredDate != null) 'preferredDate': preferredDate,
      if (preferredTime != null) 'preferredTime': preferredTime,
    };
  }
}

int _readInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _readNullableInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

DateTime? _readDateTime(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value.trim());
  return null;
}
