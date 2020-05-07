import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/widgets/sharktrack_qr_image.dart';
import 'package:oltrace/widgets/product_list_item.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/framework/util.dart' as util;

final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();

class MasterContainerFormScreen extends StatefulWidget {
  final List<Product> initialProducts;
  final LocationProvider _locationProvider = LocationProvider();

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

  List<Product> _childProducts = <Product>[];
  String _tagCode;
  String _qrLabel() => 'Master Container (${_childProducts.length} tags)';

  @override
  initState() {
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
      tripId: widget.sourceTripId
    );

    await _masterContainerRepo.store(masterContainer);
    await _exportQR();
    Navigator.pop(context);
  }

  Future<void> _onPressAddProducts() async {
    final List<Product> newProducts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AddProductsScreen(
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

  Future<void> _shareQR() async {
    final Uint8List pngBytes = await util.imageSnapshot(_renderObjectKey.currentContext.findRenderObject());
    final String filename = _getImageFilename();
    final String fullPath = await util.writeToTemp(filename, pngBytes);

    // Write to tmp
    File(fullPath).writeAsBytesSync(pngBytes);
    await Share.file('Share QR Code', filename, pngBytes, 'image/png', text: _qrLabel());
  }

  Future<bool> _exportQR() async {
    final Uint8List bytes = await util.imageSnapshot(_renderObjectKey.currentContext.findRenderObject());
    final String fullPath = await util.writeToTemp(_getImageFilename(), bytes);

    return await GallerySaver.saveImage(fullPath, albumName: AppConfig.APP_TITLE);
  }

  Future<void> _onLongPressQrCode() async {
    bool success = await _exportQR();
    if (success) {
      util.showTextSnackBar(_scaffoldKey, 'QR image saved to SharkTrack gallery.');
    }
  }

  Widget _productList() {
    if (_childProducts.length == 0) {
      return Text('No source tags');
    }
    return SingleChildScrollView(
      child: Column(
        children: _childProducts.map<Widget>((Product product) {
          return ProductListItem(
            product: product,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProductScreen(productId: product.id)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _bottomButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            color: Colors.green,
            onPressed: _onPressSave,
            disabled: _childProducts.length == 0 || _tagCode == '',
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
    return SharkTrackQrImage(
      onPressed: _shareQR,
      onLongPress: _onLongPressQrCode,
      data: _tagCode,
      title: _tagCode,
      subtitle: _qrLabel(),
      renderKey: _renderObjectKey,
    );
  }

  Widget _form() {
    return Column(
      children: <Widget>[
//        _tagCodeInput(),
//        SizedBox(height: 10),
        if (_tagCode != '') _qrCode(),
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
        title: Text('New Master Container'),
      ),
      body: _body(),
    );
  }
}

class _AddProductsScreen extends StatefulWidget {
  final List<Product> alreadySelectedProducts;
  final int sourceTripId;

  _AddProductsScreen({this.alreadySelectedProducts = const [], this.sourceTripId}) : assert(sourceTripId != null);

  @override
  _AddProductsScreenState createState() => _AddProductsScreenState(alreadySelectedProducts);

  Future<List<Product>> _load(int sourceTripId) async {
    final productRepo = ProductRepository();
    return await productRepo.forTrips([sourceTripId]);
  }
}

class _AddProductsScreenState extends State<_AddProductsScreen> {
  final List<Product> _alreadySelectedProducts;

  List<Product> _products = <Product>[];
  List<Product> _selectedProducts = <Product>[];

  _AddProductsScreenState(this._alreadySelectedProducts);

  void _onPressListItem(Product product) {
    setState(() {
      if (_selectedProducts.contains(product)) {
        _selectedProducts.remove(product);
      } else {
        _selectedProducts.add(product);
      }
    });
  }

  Widget _noProducts() {
    return Center(
      child: Text('No eligble tags in this Trip'),
    );
  }

  Widget _productList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (_, int index) {
        final Product product = _products[index];
        return ProductListItem(
          onPressed: () => _onPressListItem(product),
          product: product,
          selected: _selectedProducts.contains(product),
          trailingIcon: false,
        );
      },
    );
  }

  void _onPressAddSelectedStripButton() {
    Navigator.pop(context, _selectedProducts);
  }

  Widget _bottomButton() {
    return StripButton(
      icon: Icon(Icons.add),
      color: _selectedProducts.length == 0 ? Colors.grey : Colors.green,
      labelText: 'Add Selected',
      onPressed: _selectedProducts.length == 0 ? null : _onPressAddSelectedStripButton,
    );
  }

  Widget _body() {
    if (_products.length == 0) {
      return _noProducts();
    }
    return Column(
      children: <Widget>[
        Expanded(
          child: _productList(),
        ),
        _bottomButton(),
      ],
    );
  }

  AppBar _appBar() {
    final int nSelected = _selectedProducts.length;

    if (nSelected == 0) {
      return AppBar(
        title: Text('Select Products'),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.cancel),
        onPressed: _clearSelected,
      ),
      title: Text('$nSelected selected'),
    );
  }

  void _clearSelected() {
    setState(() {
      _selectedProducts = <Product>[];
    });
  }

  void _excludeAlreadySelected(List<Product> products) {
    products.retainWhere(
      (Product p) => _alreadySelectedProducts.singleWhere((Product asp) => asp == p, orElse: () => null) == null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget._load(widget.sourceTripId),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }
        _products = snapshot.data as List<Product>;

        _excludeAlreadySelected(_products);
//        _products.retainWhere(
//          (Product p) => _alreadySelectedProducts.singleWhere((Product asp) => asp == p, orElse: () => null) == null,
//        );
        return Scaffold(
          appBar: _appBar(),
          body: _body(),
        );
      },
    );
  }
}
