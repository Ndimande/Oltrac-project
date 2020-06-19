import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip_upload.dart';
import 'package:oltrace/providers/dio.dart';

class DdmApi {
  static final Dio dio = DioProvider().dio;

  static Future<void> uploadTrip(TripUploadData data) async {
    final String imei = await ImeiPlugin.getImei();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'SharkTrace-Version': AppData.packageInfo.version,
      'SharkTrace-App': AppData.packageInfo.appName,
      'SharkTrace-ID': AppData.packageInfo.packageName,
      'SharkTrace-Debug': AppConfig.debugMode.toString(),
      'SharkTrace-IMEI': imei,
      'SharkTrace-Locale': Platform.localeName,
      'SharkTrace-Device': AppData.deviceInfo.manufacturer + ' ' + AppData.deviceInfo.model,
      'SharkTrace-AndroidVersion': AppData.deviceInfo.version.toString(),

    };

    final String json = jsonEncode(data.toMap());

    final Response response = await dio.post(
      AppConfig.TRIP_UPLOAD_URL,
      data: json,
      options: RequestOptions(headers: headers),
    );

    print('Response:');
    printWrapped(response.toString());
  }
}
