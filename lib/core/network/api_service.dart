import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:e_learning/core/constants/endpoint_constants.dart';
import 'package:flutter/foundation.dart';

typedef TokenProvider = Future<String?> Function();

class ApiService {
  ApiService(this._dio, {TokenProvider? tokenProvider})
    : _tokenProvider = tokenProvider {
    _dio.options = BaseOptions(
      baseUrl: EndpointConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          log(
            'API error: ${error.requestOptions.method} ${error.requestOptions.uri}',
            error: error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
          logPrint: (object) {
            log(object.toString(), name: 'Dio');
          },
        ),
      );
    }
  }

  final Dio _dio;
  TokenProvider? _tokenProvider;

  Dio get client => _dio;

  void updateTokenProvider(TokenProvider provider) {
    _tokenProvider = provider;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> uploadWithTimeout<T>(
    String path, {
    required FormData data,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      options: Options(
        sendTimeout: sendTimeout ?? const Duration(minutes: 5),
        receiveTimeout: receiveTimeout ?? const Duration(minutes: 2),
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    return _dio.post<T>(path, data: formData, queryParameters: queryParameters);
  }
}
