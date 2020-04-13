import 'dart:io';
import 'dart:typed_data';

import 'package:esys_flutter_share/esys_flutter_share.dart';
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
import 'package:oltrace/widgets/SharkTrackQrImage.dart';
import 'package:oltrace/widgets/product_list_item.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/framework/util.dart' as util;

final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();

class MasterContainerFormScreen extends StatefulWidget {
  final List<Product> initialProducts;
  final LocationProvider _locationProvider = LocationProvider();
  final TextEditingController _tagCodeController = TextEditingController();

  MasterContainerFormScreen({this.initialProducts = const <Product>[]});

  @override
  _MasterContainerFormScreenState createState() => _MasterContainerFormScreenState();
}

class _MasterContainerFormScreenState extends State<MasterContainerFormScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _renderObjectKey = GlobalKey();

  List<Product> _childProducts = <Product>[];

  String _qrLabel() => 'Master Container (${_childProducts.length} tags)';

  Future<void> _onPressSave() async {
    final Location location = await widget._locationProvider.location;

    final MasterContainer masterContainer = MasterContainer(
      tagCode: widget._tagCodeController.text,
      createdAt: DateTime.now(),
      location: location,
      products: _childProducts,
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
        ),
      ),
    );
    if (newProducts != null) {
      setState(() {
        // todo keep old ones
        _childProducts.addAll(newProducts);
      });
    }
  }

  void _onPressGenerate() {
    setState(() {
      widget._tagCodeController.text = randomTagCode();
    });
  }

  String _getImageFilename() {
    const String prefix = 'st';
    final String nonce = (DateTime.now().millisecondsSinceEpoch % 100).toString();
    const String extension = 'png';
    final String tagCode = widget._tagCodeController.text;
    return '${prefix}_${tagCode}_$nonce.$extension';
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
      return Text('No Source products');
    }
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: _childProducts.map<Widget>((Product product) {
            return ProductListItem(product: product);
          }).toList(),
        ),
      ),
    );
  }

  Widget _tagCodeInput() {
    return Column(
      children: <Widget>[
        Text('Tag Code'),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  autofocus: true,
                  controller: widget._tagCodeController,
                  onChanged: (String text) => setState(() {}),
                ),
              ),
            ),
            RaisedButton(
              child: Text('Generate'),
              onPressed: _onPressGenerate,
            ),
          ],
        ),
      ],
    );
  }

  Widget _form() {
    return Expanded(
      child: Column(
        children: <Widget>[
          _tagCodeInput(),
          SizedBox(height: 10),
          if (widget._tagCodeController.text != '') _qrCode(),
          _productList(),
        ],
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
            disabled: _childProducts.length == 0 || widget._tagCodeController.text == '',
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
      data: widget._tagCodeController.text,
      title: widget._tagCodeController.text,
      subtitle: _qrLabel(),
      renderKey: _renderObjectKey,
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        _form(),
        _bottomButtons(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Create Master Container'),
      ),
      body: _body(),
    );
  }
}

class _AddProductsScreen extends StatefulWidget {
  final List<Product> alreadySelectedProducts;

  _AddProductsScreen({this.alreadySelectedProducts = const []});

  @override
  __AddProductsScreenState createState() => __AddProductsScreenState(alreadySelectedProducts);

  Future<List<Product>> _load() async {
    final ProductRepository productRepo = ProductRepository();
    final List<int> alreadySelectedProductIds =
        alreadySelectedProducts.map<int>((Product product) => product.id).toList();

    if (alreadySelectedProductIds.length == 0) {
      return await productRepo.all();
    } else {
      final String commaSeparatedIds = alreadySelectedProductIds.join(',');
      final String sqlWhere = 'NOT id IN ($commaSeparatedIds)';

      return await productRepo.all(where: sqlWhere);
    }
  }
}

class __AddProductsScreenState extends State<_AddProductsScreen> {
  List<Product> _products = <Product>[];
  List<Product> _selectedProducts = <Product>[];

  __AddProductsScreenState(this._products);

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
      child: Text('No products available'),
    );
  }

  Widget _productList() {
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (_, int index) {
        return ProductListItem(
          onPressed: () => _onPressListItem(_products[index]),
          product: _products[index],
          selected: _selectedProducts.contains(_products[index]),
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
      labelText: 'Add Selected',
      onPressed: _onPressAddSelectedStripButton,
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
        title: Text('Add Products'),
      );
    }

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.cancel),
        onPressed: _clearSelected,
      ),
      title: Text('$nSelected Selected'),
    );
  }

  void _clearSelected() {
    setState(() {
      _selectedProducts = <Product>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget._load(),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }
        _products = snapshot.data as List<Product>;
        return Scaffold(
          appBar: _appBar(),
          body: _body(),
        );
      },
    );
  }
}
