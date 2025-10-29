// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import '../errors/failures.dart';
import '../utils/logger.dart';

class ApiClient {
  final Dio _dio;
  final Logger _logger;

  ApiClient({
    required String baseUrl,
    required Logger logger,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 3),
          ),
        ),
        _logger = logger {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('API Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('API Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e(
            'API Error: ${error.message}',
            error: error,
            stackTrace: error.stackTrace,
          );
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  T _handleResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (parser != null) {
        return parser(response.data);
      }
      return response.data as T;
    }
    throw ServerFailure(
      message: 'Unexpected status code: ${response.statusCode}',
    );
  }

  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return NetworkFailure(
          message: 'Connection timeout',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'No internet connection',
          code: 'NO_CONNECTION',
        );
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          if (response.statusCode == 401) {
            return ServerFailure(
              message: 'Unauthorized',
              code: 'UNAUTHORIZED',
            );
          }
          if (response.statusCode == 422) {
            return ValidationFailure(
              message: 'Validation failed',
              errors: _extractValidationErrors(response.data),
              code: 'VALIDATION_ERROR',
            );
          }
        }
        return ServerFailure(
          message: 'Server error',
          code: 'SERVER_ERROR',
        );
      default:
        return ServerFailure(
          message: error.message ?? 'Unknown error',
          code: 'UNKNOWN',
        );
    }
  }

  Map<String, String> _extractValidationErrors(dynamic data) {
    if (data is Map) {
      final errors = <String, String>{};
      data.forEach((key, value) {
        if (value is List) {
          errors[key] = value.first.toString();
        } else {
          errors[key] = value.toString();
        }
      });
      return errors;
    }
    return {};
  }
}