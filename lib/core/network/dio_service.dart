import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class DioService {
  factory DioService() {
    return _instance;
  }

  // Private constructor for singleton pattern
  DioService._privateConstructor();

  Future<void> init() async {
    _dio = Dio(BaseOptions(
        baseUrl: 'http://api.xn--b1ab5acc.site',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'}));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );

    _dio.interceptors.add(CookieManager(cookieJar));
  }

  static final DioService _instance = DioService._privateConstructor();

  late final Dio _dio;

  /// Performs a GET request.
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a POST request.
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a PUT request.
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request.
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

/// Handles Dio errors and converts them to a user-friendly [ApiException].
ApiException _handleError(DioException e) {
  var errorMessage = 'An unexpected error occurred.';

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      errorMessage = 'Connection timeout. '
          'Please check your '
          'internet connection.';
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode != null) {
        if (statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        } else if (statusCode >= 400) {
          errorMessage = 'Bad request. Please check your input.';
        }
      }
    case DioExceptionType.cancel:
      errorMessage = 'Request was cancelled.';
    case DioExceptionType.connectionError:
      errorMessage = 'No internet connection.';
    case DioExceptionType.unknown:
    // ignore: no_default_cases
    default:
      errorMessage = 'An unknown error occurred.';
  }

  return ApiException(errorMessage);
}

/// A custom exception class for API errors.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class MyFuckingCookieInterceptor extends PersistCookieJar {
  MyFuckingCookieInterceptor({super.storage});

  @override
  Future<void> saveFromResponse(Uri uri, List<Cookie> cookies) {
    final cleaned = cookies.map((c) {
      if (c.name == 'jwt' && c.value.startsWith('Bearer ')) {
        return Cookie(c.name, c.value.replaceFirst('Bearer ', ''));
      }
      return c;
    }).toList();
    return super.saveFromResponse(uri, cleaned);
  }
}
