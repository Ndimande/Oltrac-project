import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/framework/util.dart' as util;
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/screens/master_container/add_products.dart';
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/widgets/product_list_item.dart';
import 'package:oltrace/widgets/sharktrace_qr_image.dart';

class MasterContainerFormScreen extends StatefulWidget {
  final List<Product> initialProducts;
  final LocationProvider _locationProvider = LocationProvider();
  final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();

  /// The trips we can choose products from
  final int sourceTripId;

  MasterContainerFormScreen({this.initialProducts = const <Product>[], this.sourceTripId});

  @override
  _MasterContainerFormScreenState createState() {
    return _MasterContainerFormScreenState();
  }
}

class _MasterContainerFormScreenState extends State<MasterContainerFormScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _renderObjectKey = GlobalKey();

  final List<Product> _childProducts = <Product>[];
  String _tagCode;

  String _qrLabel() => 'Master Container (${_childProducts.length} tags)';

  @override
  void initState() {
    super.initState();
    _tagCode = randomTagCode();
  }

  Future<void> _onPressSave() async {
    if (_childProducts.isEmpty) {
      showTextSnackBar(_scaffoldKey, 'You must add at least one source Tag.');
      return;
    }
    final Location location = await widget._locationProvider.location;

    final MasterContainer masterContainer = MasterContainer(
      tagCode: _tagCode,
      createdAt: DateTime.now(),
      location: location,
      products: _childProducts,
      tripId: widget.sourceTripId,
    );

    await widget._masterContainerRepo.store(masterContainer);

    Navigator.pop(context);
  }

  Future<void> _onPressAddProducts() async {
    final List<Product> newProducts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductsScreen(
          alreadySelectedProducts: _childProducts,
          sourceTripId: widget.sourceTripId,
        ),
      ),
    );

    if (newProducts != null) {
      setState(() {
        _childProducts.addAll(newProducts);
      });
    }
  }

  String _getImageFilename() {
    const String prefix = 'st';
    final String nonce = (DateTime.now().millisecondsSinceEpoch % 100).toString();
    const String extension = 'png';
    return '${prefix}_${_tagCode}_$nonce.$extension';
  }

//  Future<void> _shareQR() async {
//    final Uint8List pngBytes = await util.imageSnapshot(_renderObjectKey.currentContext.findRenderObject());
//    final String filename = _getImageFilename();
//    final String fullPath = await util.writeToTemp(filename, pngBytes);
//
//    // Write to tmp
//    File(fullPath).writeAsBytesSync(pngBytes);
//    await Share.file('Share QR Code', filename, pngBytes, 'image/png', text: _qrLabel());
//  }

  Future<bool> _exportQR() async {
    final Uint8List bytes = await util.imageSnapshot(_renderObjectKey.currentContext.findRenderObject());
    final String fullPath = await util.writeToTemp(_getImageFilename(), bytes);

    return await GallerySaver.saveImage(fullPath, albumName: AppConfig.APP_TITLE);
  }

//  Future<void> _onLongPressQrCode() async {
//    final bool success = await _exportQR();
//    if (success) {
//      util.showTextSnackBar(_scaffoldKey, 'QR image saved to SharkTrack gallery.');
//    }
//  }

  Widget _noSourceTags() {
    return const Center(
      child: Text(
        'Add tags to create Master Container.',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _productList() {
    if (_childProducts.isEmpty) {
      return _noSourceTags();
    }
    return Column(
      children: _childProducts.map<Widget>((Product product) {
        return ProductListItem(
          product: product,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductScreen(productId: product.id)),
          ),
        );
      }).toList(),
    );
  }

  Widget _bottomButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            color: OlracColours.ninetiesGreen,
            onPressed: _onPressSave,
            disabled: _childProducts.isEmpty || _tagCode == '',
            labelText: 'Save',
            icon: Icon(
              Icons.save,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StripButton(
            onPressed: _onPressAddProducts,
            labelText: 'Add Tags',
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _qrCode() {
    return SharkTraceQrImage(
      data: _tagCode,
      title: _tagCode,
      subtitle: _qrLabel(),
      renderKey: _renderObjectKey,
    );
  }

  Widget _form() {
    return Column(
      children: <Widget>[
        _qrCode(),
        _productList(),
      ],
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _form())),
        _bottomButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('New Master Container'),
      ),
      body: _body(),
    );
  }
}
