import 'package:dio/dio.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_api_service.dart';
import 'package:petsafe_movil_app/features/vaccinations/data/vaccination_models.dart';

class VaccinationRepository {
  VaccinationRepository({required VaccinationApiService apiService})
      : _apiService = apiService;

  final VaccinationApiService _apiService;

  Future<VaccinationPlan> loadPatientPlan(int patientId) async {
    try {
      return await _apiService.getPatientPlan(patientId);
    } on DioException catch (error) {
      throw ApiFailure.fromDioException(error);
    } catch (error) {
      throw ApiFailure.fromError(error);
    }
  }

  Future<VaccinationApplicationsResult> loadPatientApplications(int patientId) async {
    try {
      return await _apiService.getPatientApplications(patientId);
    } on DioException catch (error) {
      throw ApiFailure.fromDioException(error);
    } catch (error) {
      throw ApiFailure.fromError(error);
    }
  }
}
