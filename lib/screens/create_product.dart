import 'package:flutter/material.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/packaging_types.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/packaging_type.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/model_dropdown.dart';
import 'package:oltrace/widgets/shark_info_card.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/svg_icon.dart';

final _landingRepo = LandingRepository();

enum DialogResult { Yes, No, DoneTagging }

class CreateProductScreen extends StatefulWidget {
  final Haul sourceHaul;
  final List<Landing> initialSourceLandings;

  final Geolocator geoLocator = Geolocator();
  final int listIndex;
  final ProductRepository _productRepository = ProductRepository();

  CreateProductScreen({
    @required this.initialSourceLandings,
    @required this.sourceHaul,
    this.listIndex,
  })  : assert(sourceHaul != null),
        assert(initialSourceLandings != null);

  @override
  State<StatefulWidget> createState() => CreateProductScreenState(initialSourceLandings);
}

class CreateProductScreenState extends State<CreateProductScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Landing> _sourceLandings;
  ProductType _productType;
  PackagingType _packagingType;

  String _tagCode = AppConfig.debugMode ? randomTagCode() : null;
  final TextEditingController _productUnitsController = TextEditingController();
  final TextEditingController _tagCodeController = TextEditingController();

  CreateProductScreenState(List<Landing> initialSourceLandings)
      : this._sourceLandings = initialSourceLandings != null ? initialSourceLandings : [];

  @override
  void initState() {
    super.initState();
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

  List<String> getValidationErrors() {
    List<String> errorMessages = [];
    if (_productUnitsController.value == null || _productUnitsController.value.text == '') {
      errorMessages.add('Invalid quantity.');
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

  Future<void> _onPressSaveButton() async {
    final List<String> errorMessages = getValidationErrors();

    final int productUnits = int.tryParse(_productUnitsController.text);
    if (productUnits == null) {
      errorMessages.add('Invalid Quantity');
    }

    if (errorMessages.length != 0) {
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
      landings: _sourceLandings,
      productUnits: productUnits,
    );

    // Create a product
    final int savedProductId = await widget._productRepository.store(product.copyWith(landings: _sourceLandings));
    final Product savedProduct = product.copyWith(id: savedProductId);

    setState(() {
      _tagCode = null;
      _productType = null;
      _packagingType = null;
      _productUnitsController.clear();
      _tagCodeController.clear();
    });

    DialogResult result = await _showProductSavedDialog(savedProduct);
    if (result == DialogResult.Yes) {
      return;
    }

    if (result == DialogResult.No) {
      Navigator.pop(context);
      return;
    } else if (result == DialogResult.DoneTagging) {
      // mark all source landings done
      for (Landing landing in _sourceLandings) {
        await _landingRepo.store(landing.copyWith(doneTagging: true));
      }
    }
    Navigator.pop(context);
  }

  void _onPressDialogYes() {
    Navigator.of(context).pop(DialogResult.Yes);
  }

  void _onPressDialogNo() {
    Navigator.of(context).pop(DialogResult.No);
  }

  void _onPressDialogDone() {
    Navigator.of(context).pop(DialogResult.DoneTagging);
  }

  bool hasChanged() {
    return _tagCode != null;
  }

  Future<bool> get onWillPop async {
    // Have things changed since the initial state?
    final bool changed = hasChanged();

    // If there are changes warn the user before navigating away
    if (changed) {
      bool confirmed = await showDialog<bool>(
        context: _scaffoldKey.currentContext,
        builder: (_) => ConfirmDialog(
            'Cancel', 'Your unsaved changes will be lost. Are you sure you want to cancel creating this product tag?'),
      );

      if (confirmed != true) {
        return false;
      }
    }

    return true;
  }

  Future<DialogResult> _showProductSavedDialog(Product product) {
    const actionStyle = TextStyle(fontSize: 26, color: Colors.white);
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
              child: Text('Not now', style: actionStyle),
              onPressed: _onPressDialogNo,
            ),
          ),
          Container(
            child: FlatButton(
              child: Text('Completed', style: actionStyle),
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
                color: Colors.white,
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

  Widget _productUnitsTextInput() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Quantity',
              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              helperText: 'The total number of products associated with the tag',
            ),
            style: TextStyle(fontSize: 30),
            keyboardType: TextInputType.number,
            controller: _productUnitsController,
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
              decoration: new BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]))),
              child: SharkInfoCard(showIndex: false, landing: sl, listIndex: 1),
              height: 80,
            ),
          )
          .toList(),
    );
  }

  Widget _tagCodeInput() {
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

  Widget _productTypeDropdown() {
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

  Widget _packagingTypeDropdown() {
    return ModelDropdown<PackagingType>(
      label: 'Packaging Type',
      selected: _packagingType,
      items: packagingTypes.map<DropdownMenuItem<PackagingType>>(
        (PackagingType packagingType) {
          return DropdownMenuItem<PackagingType>(
            value: packagingType,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(packagingType.name),
                  Container(
                    child: SvgIcon(
                      assetPath: SvgIcons.path(packagingType.name.toLowerCase()),
                      darker: true,
                      height: packagingType.name.toLowerCase() == 'ring' ? 25 : 40,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ).toList(),
      onChanged: (PackagingType packagingType) {
        setState(() => _packagingType = packagingType);
      },
    );
  }

  StripButton get saveButton => StripButton(
        icon: Icon(Icons.save, color: Colors.white),
        labelText: 'Save',
        color: Colors.green,
        onPressed: _onPressSaveButton,
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text('Tag Product')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    // Source landing
                    _sourceLandingsList(),
                    //Product Type
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: _productTypeDropdown(),
                    ),

                    // Packaging
                    Container(padding: EdgeInsets.symmetric(horizontal: 15), child: _packagingTypeDropdown()),

                    // Quantity
                    Container(padding: EdgeInsets.symmetric(horizontal: 15), child: _productUnitsTextInput()),

                    // Tag code
                    _productType == null || _packagingType == null ? Container() : _tagCodeInput(),
                    SizedBox(height: 10),
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
