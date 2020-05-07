import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';

class DdmApi {
  static Future<void> uploadTrip(UploadTripData data) async {
    final Dio dio = Dio();

    // Accept self signed cert
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };
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

class UploadTripData {
  final UploadTripDataJson json;

  UploadTripData({@required this.json});

  Map toMap() {
    return {
      'datetimereceived': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      'json': json.toMap(),
    };
  }
}

class UploadTripDataJson {
  final UploadTripDataJsonTrip trip;
  final Map<String, dynamic> user;

  UploadTripDataJson({@required this.trip, @required this.user});

  Map toMap() {
    return {'trip': trip.toMap(), 'user': user};
  }
}

class UploadTripDataJsonTrip {
  final List<MasterContainer> masterContainers;

  UploadTripDataJsonTrip({@required this.masterContainers});

  Map toMap() {
    final List<Map> reformatted = masterContainers.map((MasterContainer mc) => mc.toMap()).toList().map((Map item) {
      final List<Product> productsList = item['products'];
      final List<Map<String, String>> tagCodes = productsList.map((Product p) => {'tagCode': p.tagCode}).toList();
      item['products'] = tagCodes;
      return item;
    }).toList();
    return {
      'masterContainers': reformatted,
    };
  }
}
