import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sqflite/sqflite.dart';

final _productRepo = ProductRepository();
final _landingRepo = LandingRepository();

final Database db = DatabaseProvider().database;

enum Actions {
  ShareQR,
  SaveQR,
}

Future<Product> _load(int productId) async {
  final List<Map<String, dynamic>> results = await db.query('products', where: 'id= $productId');

  if (results.length == 0) {
    return null;
  }
  assert(results.length == 1);
  final Product product = _productRepo.fromDatabaseMap(results.first);
  final List<Landing> landings = await _getLandings(productId);
  final List<Landing> landingsWithProducts = [];
  for (Landing landing in landings) {
    final List<Product> products = await _productRepo.forLanding(landing.id);
    landingsWithProducts.add(landing.copyWith(products: products));
  }
  return product.copyWith(landings: landingsWithProducts);
}

Future<List<Landing>> _getLandings(int productId) async {
  final List<Map> results = await db.query('product_has_landings', where: 'product_id = $productId');

  List landings = <Landing>[];
  for (Map<String, dynamic> result in results) {
    final int landingId = result['landing_id'];
    final List<Map> landingResults = await db.query('landings', where: 'id = $landingId');
    if (landingResults.length != 0) {
      final Landing landing = _landingRepo.fromDatabaseMap(landingResults.first);
      landings.add(landing);
    }
  }

  return landings;
}

class ProductScreen extends StatefulWidget {
  final int productId;

  ProductScreen({this.productId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _renderObjectKey = GlobalKey();

  Product _product;

  Future<void> _onPressLanding(Landing landing, int landingIndex) async {
    assert(landing.id != null);
    assert(landingIndex != null);

    await Navigator.pushNamed(_scaffoldKey.currentContext, '/landing', arguments: {
      'landingId': landing.id,
      'listIndex': landingIndex,
    });
  }

  Future<ui.Image> _saveQRRenderAsImage() async {
    final RenderRepaintBoundary boundary = _renderObjectKey.currentContext.findRenderObject();
    return await boundary.toImage(pixelRatio: 3);
  }

  Future<Uint8List> _getImageByteStream(ui.Image image) async {
    final ByteData pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return pngBytes.buffer.asUint8List();
  }

  String _getImageFilename() {
    const String prefix = 'st';
    final String nonce = (DateTime.now().millisecondsSinceEpoch % 100).toString();
    const String extension = 'png';
    return '${prefix}_${_product.tagCode}_$nonce.$extension';
  }

  Future<String> _getOutputPath(String filename) async {
    final Directory tmp = await getTemporaryDirectory();
    return '${tmp.path}/$filename';
  }

  Future<void> _onPressShareQR() async {
    final ui.Image image = await _saveQRRenderAsImage();
    final Uint8List byteStream = await _getImageByteStream(image);

    final String filename = _getImageFilename();
    final String fullPath = await _getOutputPath(filename);

    // Write to tmp
    File(fullPath).writeAsBytesSync(byteStream);
    await Share.file('Share QR Code', filename, byteStream, 'image/png', text: _qrLabel());
  }

  Future<void> _onPressExportQR() async {
    final ui.Image image = await _saveQRRenderAsImage();
    final Uint8List byteStream = await _getImageByteStream(image);

    final String filename = _getImageFilename();
    final String fullPath = await _getOutputPath(filename);

    print(fullPath);

    // Write to tmp
    File(fullPath).writeAsBytesSync(byteStream);
    final bool success = await GallerySaver.saveImage(fullPath, albumName: AppConfig.APP_TITLE);
    if (success) {
      showTextSnackBar(_scaffoldKey, 'QR image saved to SharkTrack gallery.');
    }
  }

  String _qrLabel() {
    final String packageType = _product.packagingType.name;
    final String productType = _product.productType.name;
    final String quantity = _product.productUnits.toString();

    return '$productType ($quantity) - $packageType';
  }

  Widget _qrCode() {
    final String code = _product.tagCode;

    final String labelText = _qrLabel();

    final String helpText = 'This QR code may be used instead of the RFID tag for convenience '
        'if no RFID reader is available or the tags are hard to access for scanning.';
    return ExpansionTile(
      title: Text(
        'QR Code',
        style: TextStyle(color: olracBlue, fontSize: 22),
      ),
      children: <Widget>[
        FlatButton(
          padding: EdgeInsets.all(0),
          onPressed: _onPressShareQR,
          onLongPress: _onPressExportQR,
          child: RepaintBoundary(
            key: _renderObjectKey,
            child: Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  QrImage(
                    data: _product.tagCode,
                    version: QrVersions.auto,
                    size: 200.0,
                    embeddedImage: AssetImage('assets/images/shark_track_icon_bw.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(size: Size(36, 36)),
                  ),
                  Text(
                    code,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    labelText,
                    style: TextStyle(fontSize: 11),
                  )
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            helpText,
            style: TextStyle(fontSize: 12),
          ),
        ),
        _qrStripButtons(),
      ],
    );
  }

  Widget _qrStripButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            labelText: 'Share',
            onPressed: _onPressShareQR,
            icon: Icon(Icons.share),
            color: olracBlue,
          ),
        ),
        Expanded(
          child: StripButton(
            labelText: 'Save',
            onPressed: _onPressExportQR,
            icon: Icon(Icons.save_alt),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String lhs, String rhs) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              lhs,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: Text(
              rhs,
              style: TextStyle(fontSize: 18),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _landingItems() {
    int listIndex = 1;

    final List<Widget> landingItems = _product.landings
        .map<Widget>((Landing l) => LandingListItem(
            landing: l, listIndex: listIndex++, onPressed: (int index) async => await _onPressLanding(l, listIndex)))
        .toList();

    return ExpansionTile(
      title: Text(
        'Source Sharks',
        style: TextStyle(fontSize: 22, color: olracBlue),
      ),
      children: landingItems,
    );
  }

  Widget _locationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Location',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        LocationButton(location: _product.location),
      ],
    );
  }

  Widget _details() {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Text('RFID Tag Code',style: TextStyle(fontSize: 12),),
          Text(_product.tagCode,style: TextStyle(fontSize: 32),),
          _locationRow(),
          _detailRow('Packaging Type', _product.packagingType.name),
          _detailRow('Product Type', _product.productType.name),
          _detailRow('Quantity', _product.productUnits.toString()),
          _detailRow('Created At', friendlyDateTime(_product.createdAt)),
        ],
      ),
    );
  }

  Widget scrollViewChild() {
    return Container(
      child: Column(
        children: <Widget>[
          _details(),
          _landingItems(),
          _qrCode(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(widget.productId),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }

        _product = snapshot.data;

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Product (${_product.productType.name})'),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                  child: SingleChildScrollView(
                child: scrollViewChild(),
              ))
            ],
          ),
        );
      },
    );
  }
}
