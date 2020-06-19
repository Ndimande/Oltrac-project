import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:intl/intl.dart';
import 'package:oltrace/app_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry/sentry.dart';
import 'package:uuid/uuid.dart';

String friendlyDateTime(DateTime dateTime) {
  return dateTime == null ? null : DateFormat('d MMM y, HH:mm').format(dateTime);
}

String friendlyDate(DateTime dateTime) {
  return dateTime == null ? null : DateFormat('d MMM y').format(dateTime);
}

enum WeightUnit { GRAMS, OUNCES }

enum LengthUnit { MICROMETERS, INCHES }

String randomTagCode() => Uuid().v4();

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showTextSnackBar(
  GlobalKey<ScaffoldState> scaffoldKey,
  String text, {
  duration = const Duration(seconds: 2),
}) =>
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(text), duration: duration));

/// Rounds [value] to given number of [decimals]
double roundDouble(final double value, {final int decimals = 6}) =>
    (value * math.pow(10, decimals)).round() / math.pow(10, decimals);

Future<Uint8List> _getPngBytes(ui.Image image) async {
  final ByteData pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return pngBytes.buffer.asUint8List();
}

Future<Uint8List> imageSnapshot(RenderRepaintBoundary boundary, {double pixelRatio = 3.0}) async {
  final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
  final Uint8List pngBytes = await _getPngBytes(image);
  return pngBytes;
}

Future<String> writeToTemp(String filename, Uint8List bytes) async {
  final Directory tmpDir = await getTemporaryDirectory();
  final String fullPath = '${tmpDir.path}/$filename';
  File('${tmpDir.path}/$filename').writeAsBytesSync(bytes);
  return fullPath;
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => print(match.group(0)));
}

void setFlutterErrorHandler() {
  FlutterError.onError = (details, {bool forceReport = false}) {
    handleError(details.exception, details.stack);
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  };
}

Future<void> _sendSentryReport(Object exception, StackTrace stack) async {
  print('Sending report to Sentry.io...');
  final sentry = SentryClient(dsn: AppConfig.SENTRY_DSN);
  try {
    await sentry.captureException(
      exception: exception,
      stackTrace: stack,
    );
    print('Sentry report sent');
  } catch (e) {
    print('Sending report to sentry.io failed: $e');
  }
}

Future<void> handleError(Object exception, StackTrace stack) async {
  print(exception);
  print(stack);
  if (AppConfig.debugMode) {
    return;
  }

  _sendSentryReport(exception, stack);
}

/// Get the IMEI to force the permissions prompt
Future<void> requestPhonecallPermission() async {
  await ImeiPlugin.getImei();
}

String prettyJson(Map<String, dynamic> json, {int indent = 2}) {
  final spaces = ' ' * indent;
  final encoder = JsonEncoder.withIndent(spaces);
  return encoder.convert(json);
}

void printPrettyJson(Map<String, dynamic> json, {int indent = 2}) {
  print(prettyJson(json, indent: indent));
}
