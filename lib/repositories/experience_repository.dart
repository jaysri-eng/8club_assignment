import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/experience.dart';

class ExperienceRepository {
  late final Dio _dio;
  late final String _apiBaseUrl;

  ExperienceRepository() {
    _apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';

    _dio = Dio(
      BaseOptions(
        baseUrl: _apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

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