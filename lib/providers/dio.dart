import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

class DioProvider {
  static final DioProvider _provider = DioProvider._();

  Dio _dio;

  DioProvider._();

  factory DioProvider() {
    return _provider;
  }

  Dio get dio {
    if (_dio == null) {
      throw Exception('Dio not initialised');
    }
    return _dio;
  }

  Dio init() {
    _dio = Dio();
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
    return _dio;
  }
}