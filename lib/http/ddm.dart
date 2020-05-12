import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/models/trip_upload.dart';
import 'package:oltrace/providers/dio.dart';

class DdmApi {
  static final Dio dio = DioProvider().dio;

  static Future<void> uploadTrip(TripUploadData data) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'SharkTrack-Version': AppData.packageInfo.version,
      'SharkTrack-App': AppData.packageInfo.appName,
      'SharkTrack-ID': AppData.packageInfo.packageName,
      'SharkTrack-Debug': AppConfig.debugMode.toString(),
    };

    final String json = jsonEncode(data.toMap());

    Response response = await dio.post(
      AppConfig.TRIP_UPLOAD_URL,
      data: json,
      options: RequestOptions(headers: headers),
    );

    print('Response:');
    print(response.toString());
  }
}
