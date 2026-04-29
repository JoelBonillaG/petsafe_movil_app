import 'package:petsafe_movil_app/features/appointments/data/appointment_api_service.dart';
import 'package:petsafe_movil_app/features/appointments/data/appointment_models.dart';

class AppointmentRepository {
  AppointmentRepository({required AppointmentApiService apiService})
      : _apiService = apiService;

  final AppointmentApiService _apiService;

  Future<List<AppointmentRequest>> loadMine() => _apiService.listMine();

  Future<AppointmentRequest> create(CreateAppointmentRequestPayload payload) =>
      _apiService.create(payload);
}
