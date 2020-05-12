import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/trip.dart';

class TripUploadData {
  final String imei;
  final Profile userProfile;
  final Trip trip;

  TripUploadData({
    @required this.imei,
    @required this.userProfile,
    @required this.trip,
  })  : assert(imei != null),
        assert(userProfile != null),
        assert(trip != null);

  Map _tripMap() {
    final tripMap = trip.toMap();
    tripMap['masterContainers'] = _formatMasterContainers(trip.masterContainers);
    return tripMap;
  }

  Map _json() {
    return {
      'trip': _tripMap(),
      'user': userProfile.toMap(),
    };
  }

 List<Map> _formatMasterContainers(List<MasterContainer> masterContainers) {
    return masterContainers.map((MasterContainer mc) => mc.toMap()).toList().map((Map item) {
      // Get products in the master container
      final List<Product> products = item['products'];

      // Strip everything from products but tag codes
      final List<Map<String, String>> tagCodes = products.map((Product p) => {'tagCode': p.tagCode}).toList();
      item['products'] = tagCodes;
      return item;
    }).toList();
  }

  Map toMap() {
    return {
      'datetimereceived': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc()),
      'json': _json(),
      'locale': Platform.localeName,
      'imei': imei,
    };
  }
}
