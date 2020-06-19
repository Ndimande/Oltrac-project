import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart' as util;
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/edit_product.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/sharktrace_qr_image.dart';
import 'package:sqflite/sqflite.dart';

enum Actions {
  ShareQR,
  SaveQR,
}

Future<Map<String, dynamic>> _load(int productId) async {
  final _productRepo = ProductRepository();
  final _haulRepo = HaulRepository();
  final _tripRepo = TripRepository();
  final Database db = DatabaseProvider().database;

  final List<Map<String, dynamic>> results = await db.query('products', where: 'id = $productId');
  assert(results.length == 1);

  final Product product = _productRepo.fromDatabaseMap(results.first);
  final List<Landing> landings = await LandingRepository().forProduct(productId);
  final int haulId = landings.first.haulId;
  final Haul haul = await _haulRepo.find(haulId);
  final Trip trip = await _tripRepo.find(haul.id);

  return {
    'product': product.copyWith(landings: landings),
    'tripIsUploaded': trip.isUploaded,
  };
}

class ProductScreen extends StatefulWidget {
  final int productId;

  const ProductScreen({@required this.productId}) : assert(productId != null);

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _renderObjectKey = GlobalKey();

  Product _product;
  bool _tripIsUploaded;

  Future<void> _onPressLanding(Landing landing, int landingIndex) async {
    assert(landing.id != null);
    assert(landingIndex != null);

    await Navigator.pushNamed(_scaffoldKey.currentContext, '/landing', arguments: {
      'landingId': landing.id,
      'listIndex': landingIndex,
    });
  }

  String _getImageFilename() {
    const String prefix = 'st';
    final String nonce = (DateTime.now().millisecondsSinceEpoch % 100).toString();
    const String extension = 'png';
    return '${prefix}_${_product.tagCode}_$nonce.$extension';
  }

  Future<void> _onPressShareQR() async {
    final Uint8List pngBytes = await util.imageSnapshot(_renderObjectKey.currentContext.findRenderObject());
    final String filename = _getImageFilename();
    final String fullPath = await util.writeToTemp(filename, pngBytes);

    // Write to tmp
    File(fullPath).writeAsBytesSync(pngBytes);
    await Share.file('Share QR Code', filename, pngBytes, 'image/png', text: _qrLabel());
  }

  Future<void> _onPressExportQR() async {
    final Uint8List bytes = await util.imageSnapshot(_renderObjectKey.currentContext.findRenderObject());
    final String fullPath = await util.writeToTemp(_getImageFilename(), bytes);

    final bool success = await GallerySaver.saveImage(fullPath, albumName: AppConfig.APP_TITLE);
    if (success) {
      util.showTextSnackBar(_scaffoldKey, 'QR image saved to ${AppConfig.APP_TITLE} gallery.');
    }
  }

  Future _onPressEdit() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProduct(product: _product)));
  }

  String _qrLabel() {
    final String packageType = _product.packagingType.name;
    final String productType = _product.productType.name;
    final String quantity = _product.productUnits.toString();

    return '$productType - $quantity - $packageType';
  }

  Widget _qrCode() {
    final String code = _product.tagCode;

    final String labelText = _qrLabel();

    const String helpText = 'This QR code may be used instead of the RFID tag for convenience '
        'if no RFID reader is available or the tags are hard to access for scanning.';

    return Column(
      children: <Widget>[
        SharkTraceQrImage(
          data: _product.tagCode,
          title: code,
          subtitle: labelText,
          onPressed: _onPressShareQR,
          onLongPress: _onPressExportQR,
          renderKey: _renderObjectKey,
        ),
        const SizedBox(height: 5),
        const Padding(
          padding: EdgeInsets.all(8.0),
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
            icon: const Icon(Icons.share),
            color: OlracColours.fauxPasBlue,
          ),
        ),
        Expanded(
          child: StripButton(
            labelText: 'Save',
            onPressed: _onPressExportQR,
            icon: const Icon(Icons.save_alt),
            color: OlracColours.ninetiesGreen,
          ),
        ),
      ],
    );
  }

  Widget _detailRow(String lhs, String rhs) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            lhs,
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            rhs,
            style: Theme.of(context).textTheme.headline6,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
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
      title: const Text(
        'Source Sharks',
        style: TextStyle(fontSize: 22, color: OlracColours.fauxPasBlue),
      ),
      children: landingItems,
    );
  }

  Widget _locationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          'Location',
          style: Theme.of(context).textTheme.headline6,
        ),
        Container(
          width: 100,
          child: LocationButton(location: _product.location),
        )
      ],
    );
  }

  Widget _details() {
    return Container(
      color: OlracColours.fauxPasBlue[100],
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Tag Code', style: Theme.of(context).textTheme.caption),
          SelectableText(_product.tagCode, style: Theme.of(context).primaryTextTheme.headline5),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Packaging Type', _product.packagingType.name),
                  _detailRow('Product Type', _product.productType.name),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Quantity', _product.productUnits.toString()),
                  _detailRow('Created At', util.friendlyDateTime(_product.createdAt)),
                ],
              )
            ],
          ),
          _locationRow(),
        ],
      ),
    );
  }

  Widget _editStripButton() {
    return StripButton(
      labelText: 'Edit',
      icon: const Icon(Icons.edit, color: Colors.white),
      onPressed: _onPressEdit,
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  _details(),
                  if (!_tripIsUploaded) _editStripButton(),
                  _qrCode(),
                  _landingItems(),
                ],
              ),
            ),
          ),
        )
      ],
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
          return const Scaffold();
        }

        _product = snapshot.data['product'];
        _tripIsUploaded = snapshot.data['tripIsUploaded'];

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Product (${_product.productType.name})'),
          ),
          body: _body(),
        );
      },
    );
  }
}
