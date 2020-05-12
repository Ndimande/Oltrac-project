import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/models/trip_upload.dart';
import 'package:oltrace/providers/dio.dart';

class DdmApi {
  static final Dio dio = DioProvider().dio;

  static Future<void> uploadTrip(TripUploadData data) async {
    final String json = jsonEncode(data.toMap());
    Response response = await dio.post(
      AppConfig.TRIP_UPLOAD_URL,
      data: json,
      options: RequestOptions(headers: {'Content-Type': 'application/json'}),
    );
    print('Response:');
    print(response.toString());
  }
}
