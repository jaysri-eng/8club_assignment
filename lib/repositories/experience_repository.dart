import 'package:dio/dio.dart';
import '../models/experience.dart';

class ExperienceRepository {
  final Dio _dio;

  ExperienceRepository()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://staging.chamberofsecrets.8club.co',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<List<Experience>> getExperiences() async {
    try {
      final response = await _dio.get('/v1/experiences?active=true');
      
      if (response.statusCode == 200) {
        final experiencesResponse = ExperiencesResponse.fromJson(response.data);
        return experiencesResponse.experiences;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load experiences',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('API Error: ${e.response?.statusCode} - ${e.message}');
      } else {
        throw Exception('Network Error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected Error: $e');
    }
  }
}