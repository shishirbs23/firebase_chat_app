import 'package:dio/dio.dart';
import 'package:firebase_chat_app/utils/app_constants.dart';

class ApiService {
  static const String baseUrl = 'https://fcm.googleapis.com';

  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json; charset=UTF-8';
    _dio.options.headers['Authorization'] = 'key=${AppConstants.serverKey}';
  }

  Future<Map<String, dynamic>?> post(
      String path, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }
}
