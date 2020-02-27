import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/packaging_types.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/packaging_type.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/widgets/shark_info_card.dart';
import 'package:oltrace/widgets/strip_button.dart';

enum DialogResult { Yes, No, DoneTagging }

class CreateProductScreen extends StatefulWidget {
  final Landing initialSourceLanding;
  final AppStore _appStore = StoreProvider().appStore;
  final Geolocator geoLocator = Geolocator();
  final int listIndex;

  CreateProductScreen(this.initialSourceLanding, this.listIndex);

  @override
  State<StatefulWidget> createState() => CreateProductScreenState(initialSourceLanding);
}

class CreateProductScreenState extends State<CreateProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Landing> _sourceLandings;
  ProductType _productType;
  PackagingType _packagingType;

  String _tagCode = AppConfig.DEV_MODE ? randomTagCode() : null;
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _tagCodeController = TextEditingController();

  CreateProductScreenState(initialSourceLanding)
      : this._sourceLandings = initialSourceLanding != null ? [initialSourceLanding] : [];

  @override
  void initState() {
    super.initState();
    // When a tag is held to the device, read the tag
    FlutterNfcReader.onTagDiscovered().listen(onTagDiscovered);
  }

  void onTagDiscovered(NfcData data) {
    print('Tag scanned!');
    print(data.id);
    print(data.content);
    print(data.hashCode);
    print(data.error);
    setState(() {
      _tagCodeController.text = data.id;
      _tagCode = data.id;
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

  List<String> getValidationErrors() {
    List<String> errorMessages = [];
    if (_totalController.value == null || _totalController.value.text == '') {
      errorMessages.add('Invalid number of products.');

    }

    if (_tagCode == null) {
      errorMessages.add('No RFID tag has been scanned.');

    }

    if (_sourceLandings.length == 0) {
      errorMessages.add('You must select at least one source tag.');
    }

    if (_productType == null) {
      errorMessages.add('No product type seletected.');
    }

    return errorMessages;
  }

  _onPressSaveButton() async {

    final List<String> errorMessages = getValidationErrors();

    if(errorMessages.length != 0) {
      showTextSnackBar(_scaffoldKey, errorMessages.join("\n"));
      return;
    }

    Position position = await widget.geoLocator.getCurrentPosition();

    final product = Product(
      tagCode: _tagCode,
      createdAt: DateTime.now(),
      location: Location.fromPosition(position),
      packagingType: _packagingType,
      productType: _productType,
      landingId: _sourceLandings[0].id,
    );

    // Create a product
    Product savedProduct = await widget._appStore.saveProduct(product);

    setState(() {
      _tagCode = null;
      _productType = null;
      _packagingType = null;
      _totalController.clear();
    });

    DialogResult result = await _showProductSavedDialog(savedProduct);
    if (result == DialogResult.Yes) {
      return;
    } else if (result == DialogResult.No) {
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 2;
      });
      return;
    } else if (result == DialogResult.DoneTagging) {
      // must get latest landing from state

      // Look through all hauls including hauls in the active trip
      final haul =
          widget._appStore.activeTrip.hauls.firstWhere((h) => _sourceLandings[0].haulId == h.id);
      final Landing landing =
          haul.landings.firstWhere((Landing l) => l.id == _sourceLandings[0].id);
      await widget._appStore.editLanding(landing.copyWith(doneTagging: true));
      int count = 0;
      Navigator.popUntil(context, (route) {
        return count++ == 2;
      });
    }
  }

  _onPressDialogYes() {
    Navigator.of(context).pop(DialogResult.Yes);
  }

  _onPressDialogNo() {
    Navigator.of(context).pop(DialogResult.No);
  }

  _onPressDialogDone() async {
    Navigator.of(context).pop(DialogResult.DoneTagging);
  }

  _onPressAddShark() async {
    final Landing additionalSource =
        await Navigator.pushNamed(context, '/add_source_landing', arguments: _sourceLandings)
            as Landing;
    if (additionalSource != null) {
      setState(() {
        _sourceLandings.add(additionalSource);
      });
    }
  }

  Future<DialogResult> _showProductSavedDialog(Product product) {
    const actionStyle = TextStyle(fontSize: 26);
    return showDialog<DialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(15),
        actions: <Widget>[
          Container(
            child: FlatButton(
              child: Text('Yes', style: actionStyle),
              onPressed: _onPressDialogYes,
            ),
          ),
          Container(
            child: FlatButton(
              child: Text('No', style: actionStyle),
              onPressed: _onPressDialogNo,
            ),
          ),
          Container(
            child: FlatButton(
              child: Text('Tagging Completed', style: actionStyle),
              onPressed: _onPressDialogDone,
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
                'Do you want to create another product?',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalTextInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Number of products',
              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              helperText: 'The total number of products associated with the tag',
            ),
            style: TextStyle(fontSize: 30),
            keyboardType: TextInputType.number,
            controller: _totalController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter total number of products';
              }

              // check if valid float
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number of products';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _sourceLandingsList() {
    return Column(
      children: _sourceLandings
          .map<Widget>(
            (Landing sl) => Container(
              decoration:
                  new BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SharkInfoCard(showIndex: false, landing: sl, listIndex: 1),
                  IconButton(
                    color: Colors.red,
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        if (_sourceLandings.length > 1) {
                          _sourceLandings.remove(sl);
                        }
                      });
                    },
                  ),
                ],
              ),
              height: 80,
            ),
          )
          .toList(),
    );
  }

  StripButton get saveButton => StripButton(
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        labelText: 'Save',
        centered: true,
        color: Colors.green,
        onPressed: _onPressSaveButton,
      );

  StripButton get addSharkButton => StripButton(
        centered: true,
        color: olracBlue,
        icon: Icon(Icons.save, color: Colors.white),
        labelText: 'Add Shark',
        onPressed: _onPressAddShark,
      );

  Future<bool> get onWillPop async {
    // Have things changed since the initial state?
    final bool changed = _sourceLandings.length > 1 || // There are at least two landings
        (_sourceLandings.length == 1 &&
            _sourceLandings[0] != widget.initialSourceLanding) || // There is one but it's different
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
  }

  Widget tagCode() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _tagCodeController,
            textCapitalization: TextCapitalization.words,
            autocorrect: false,
            style: TextStyle(fontSize: 30),
            decoration: InputDecoration(
              labelText: 'Tag code',
              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              helperText: 'Hold tag infront of reader to scan',
            ),
            onFieldSubmitted: (t) {},
            onChanged: (String enteredText) {
              setState(() {
                _tagCode = enteredText;
              });
            },
            validator: (t) => t,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Tag Product'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Source landing
                    _sourceLandingsList(),

                    addSharkButton,

                    //Product Type
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: _buildProductTypeDropdown(),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: ModelDropdown<PackagingType>(
                        label: 'Packaging Type',
                        selected: _packagingType,
                        items: packagingTypes.map<DropdownMenuItem<PackagingType>>(
                          (PackagingType packagingType) {
                            return DropdownMenuItem<PackagingType>(
                              value: packagingType,
                              child: Container(
//                                color: bgColor,
                                child: Row(
                                  children: <Widget>[
                                    Text(packagingType.name),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (PackagingType packagingType) {
                          setState(() => _packagingType = packagingType);
                        },
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: _totalTextInput(),
                    ),
                    // Tag code
                    _productType == null || _packagingType == null
                        ? Container()
                        : tagCode(),

                    // Space for FAB
                  ],
                ),
              ),
            ),
            saveButton
          ],
        ),
      ),
    );
  }
}
