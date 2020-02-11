import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/widgets/screens/tag/rfid.dart';
import 'package:oltrace/widgets/shark_info_card.dart';
import 'package:oltrace/widgets/strip_button.dart';

class CreateProductScreen extends StatefulWidget {
  final Landing initialSourceLanding;
  final AppStore _appStore = StoreProvider().appStore;
  final Geolocator geoLocator = Geolocator();

  CreateProductScreen(this.initialSourceLanding);

  @override
  State<StatefulWidget> createState() => CreateProductScreenState(initialSourceLanding);
}

class CreateProductScreenState extends State<CreateProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Landing> _sourceLandings;
  ProductType _productType;
  String _tagCode = AppConfig.DEV_MODE ? randomTagCode() : null;

  CreateProductScreenState(initialSourceLanding)
      : this._sourceLandings = initialSourceLanding != null ? [initialSourceLanding] : [];

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

  _onPressSaveButton() async {
    if (_tagCode == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('No RFID has been scanned.'),
        ),
      );
      return;
    }

    if (_sourceLandings.length == 0) {
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
      createdAt: DateTime.now(),
      location: Location.fromPosition(position),
      productType: productTypes.firstWhere((ProductType pt) => pt.id == _productType.id),
      landingId: _sourceLandings[0].id,
    );

    // Create a product
    Product savedProduct = await widget._appStore.saveProduct(product);

    setState(() {
      _tagCode = null;
      _productType = null;
    });

    bool createAnother = await _showProductSavedDialog(savedProduct);
    if (createAnother) {
      return;
    }
    Navigator.pop(context);
  }

  Future<bool> _showProductSavedDialog(Product product) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(15),
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 60),
            child: FlatButton(
              child: Text(
                'Yes',
                style: TextStyle(fontSize: 26),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ),
          Container(
            child: FlatButton(
              child: Text(
                'No',
                style: TextStyle(fontSize: 26),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ),
        ],
        content: Container(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                size: 50,
              ),
              Text(
                '${product.productType.name} Tag\n${product.tagCode}\nsaved!',
                style: TextStyle(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              Text(
                'Do you want to create another product from this shark?',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Have things changed since the initial state?
        final bool changed = _sourceLandings.length > 1 || // There are at least two landings
            (_sourceLandings.length == 1 &&
                _sourceLandings[0] !=
                    widget.initialSourceLanding) || // There is one but it's different
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
        appBar: AppBar(
          title: Text('Tag Product'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Source landing
                  Container(
                    child: SharkInfoCard(
                      landing: _sourceLandings[0],
                    ),
                  ),

                  //Product Type
                  Container(
                    padding: EdgeInsets.all(15),
                    child: _buildProductTypeDropdown(),
                  ),

                  // Tag code
                  Container(
                    alignment: Alignment.centerLeft,
                    child: RFID(
                      tagCode: _tagCode,
                      onLongPress: () => setState(
                        () {
                          _tagCode = randomTagCode();
                        },
                      ),
                    ), // Hardcode in dev mode
                  ),

                  // Space for FAB
                ],
              ),
            ),
            StripButton(
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              labelText: 'Save',
              centered: true,
              color: Colors.green,
              onPressed: _onPressSaveButton,
            ),
          ],
        ),
      ),
    );
  }
}
