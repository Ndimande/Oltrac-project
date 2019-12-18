import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/widgets/screens/tag/rfid.dart';
import 'package:oltrace/widgets/tag_list_item.dart';

class CreateProductScreen extends StatefulWidget {
  final Tag initialSourceTag;
  final AppStore _appStore = StoreProvider().appStore;
  final Geolocator geoLocator = Geolocator();

  CreateProductScreen(this.initialSourceTag);

  @override
  State<StatefulWidget> createState() => CreateProductScreenState(initialSourceTag);
}

class CreateProductScreenState extends State<CreateProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Tag> _sourceTags;
  ProductType _productType;
  String _tagCode = AppConfig.DEV_MODE ? '0xAA7E5C41' : null;

  CreateProductScreenState(initialSourceTag)
      : this._sourceTags = initialSourceTag != null ? [initialSourceTag] : [];

  @override
  void initState() {
    super.initState();
    // When a tag is held to the device, read the tag
    FlutterNfcReader.onTagDiscovered().listen((NfcData onData) {
      setState(() {
        _tagCode = onData.id;
      });
    });
  }

  Widget _buildSourceTag(Tag tag) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.local_offer),
        title: Text(tag.tagCode),
        subtitle: Text(tag.species.englishName),
        trailing: IconButton(
          icon: Icon(
            Icons.remove_circle_outline,
            color: Colors.red,
          ),
          onPressed: () => _onPressRemoveSourceTag(tag),
        ),
      ),
    );
  }

  Widget _buildSourceTags(List<Tag> tags) {
    final addButton = RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      label: Text(
        'Add Carcass',
        style: TextStyle(fontSize: 20),
      ),
      icon: Icon(Icons.add),
      onPressed: () async => await _onPressAddSourceTag(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Source Tags',
              style: TextStyle(fontSize: 20),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: addButton,
            )
          ],
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(children: tags.map((Tag t) => _buildSourceTag(t)).toList()),
        ),
      ],
    );
  }

  Widget _buildProductTypeDropdown() {
    return ModelDropdown<ProductType>(
      selected: _productType,
      label: 'Product Type',
      onChanged: (ProductType pt) => setState(() => _productType = pt),
      items: productTypes.map<DropdownMenuItem<ProductType>>((ProductType productType) {
        return DropdownMenuItem<ProductType>(
          value: productType,
          child: Text(productType.name),
        );
      }).toList(),
    );
  }

  _floatingActionButton() {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 180,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Save',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.save),
        onPressed: () async => await _onPressSaveButton(),
      ),
    );
  }

  Future<void> _onPressAddSourceTag() async {
    var tag = await Navigator.pushNamed(_scaffoldKey.currentContext, '/add_source_tag',
        arguments: _sourceTags);

    if (tag != null) {
      setState(() {
        _sourceTags.add(tag);
      });
    }
  }

  void _onPressRemoveSourceTag(Tag tag) {
    setState(() {
      _sourceTags.removeWhere((t) => t.id == tag.id);
    });
  }

  _onPressSaveButton() async {
    // TODO validate

    if (_tagCode == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('No RFID has been scanned.'),
        ),
      );
      return;
    }

    if (_sourceTags.length == 0) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('You must select at least one source tag.'),
        ),
      );
      return;
    }

    if (_productType == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('No product type seletected.'),
        ),
      );
      return;
    }

    Position position = await widget.geoLocator.getLastKnownPosition();
    if (position == null) {
      // This can take a few seconds
      position = await widget.geoLocator.getCurrentPosition();
    }
    final product = Product(
        tagCode: _tagCode,
        weight: 100, // TODO weight input field
        createdAt: DateTime.now(),
        location: Location.fromPosition(position),
        productType: productTypes.firstWhere((ProductType pt) => pt.id == _productType.id));
    // Create a product
    await widget._appStore.saveProduct(product);
    Navigator.pop<bool>(context, true);
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Product Tag saved.'),
      ),
    );
    // Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Have things changed since the initial state?
        final bool changed =
            _sourceTags.length > 1 || // There are at least two tags so things must have changed
                (_sourceTags.length == 1 &&
                    _sourceTags[0] != widget.initialSourceTag) || // There is one but it's different
                _tagCode != null; // They have scanned in a tag

        // If there are changes warn the user before navigating away
        if (changed) {
          bool confirmed = await showDialog<bool>(
            context: _scaffoldKey.currentContext,
            builder: (_) => ConfirmDialog('Cancel',
                'Your unsaved changes will be lost. Are you sure you want to cancel creating this product tag?'),
          );

          if (!confirmed) {
            return false;
          }
        }

        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: _floatingActionButton(),
        appBar: AppBar(
          title: Text('Create Product Tag'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Tag code
              Container(
                padding: EdgeInsets.all(15),
                alignment: Alignment.centerLeft,
                child: RFID(tagCode: _tagCode), // Hardcode in dev mode
              ),

              // Source tags
              Container(
                padding: EdgeInsets.all(15),
                child: _buildSourceTags(_sourceTags),
              ),

              //Product Type
              Container(
                padding: EdgeInsets.all(15),
                child: _buildProductTypeDropdown(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
