import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
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
import 'package:oltrace/widgets/source_landing_info.dart';
import 'package:oltrace/widgets/svg_icon.dart';
import 'package:olrac_widgets/westlake/westlake_text_input.dart';

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

  final TextEditingController _productUnitsController = TextEditingController();
  final TextEditingController _tagCodeController = TextEditingController();

  CreateProductScreenState(List<Landing> initialSourceLandings) : _sourceLandings = initialSourceLandings ?? [];

  @override
  void initState() {
    super.initState();
    try {
      FlutterNfcReader.onTagDiscovered().listen(onTagDiscovered);
    } on Exception {
      print('NFC reader could not be started.');
    }
  }

  @override
  void dispose() {
    FlutterNfcReader.stop().then((NfcData data) {
      print('NFC reader stopped');
    }).catchError((e) {
      print('NFC reader could not be stopped.');
    });
    super.dispose();
  }

  void onTagDiscovered(NfcData data) {
    print('Tag scanned!');
    print(data.id);
    print(data.content);
    print(data.hashCode);
    print(data.error);
    setState(() {
      _tagCodeController.text = data.id;
    });
  }

  List<String> _getValidationErrors() {
    final List<String> errorMessages = [];
    if (_productUnitsController.value == null || _productUnitsController.value.text == '') {
      errorMessages.add('Invalid Quantity.');
    }

    if (_tagCodeController.value == null || _tagCodeController.text == '') {
      errorMessages.add('No RFID tag has been scanned.');
    }

    if (_sourceLandings.isEmpty) {
      errorMessages.add('You must select at least one source tag.');
    }

    if (_productType == null) {
      errorMessages.add('No product type seletected.');
    }

    return errorMessages;
  }

  Future<void> _onPressSaveButton() async {
    final List<String> errorMessages = _getValidationErrors();

    final int productUnits = int.tryParse(_productUnitsController.text);

    if (errorMessages.isNotEmpty) {
      showTextSnackBar(_scaffoldKey, errorMessages.join('\n'));
      return;
    }

    final Position position = await widget.geoLocator.getCurrentPosition();

    final product = Product(
      tagCode: _tagCodeController.text,
      createdAt: DateTime.now(),
      location: Location.fromPosition(position),
      packagingType: _packagingType,
      productType: _productType,
      landings: _sourceLandings,
      productUnits: productUnits,
    );

    // Create a product
    final int savedProductId = await widget._productRepository.store(product);
    final Product savedProduct = product.copyWith(id: savedProductId);

    setState(() {
      _productType = null;
      _packagingType = null;
      _productUnitsController.clear();
      _tagCodeController.clear();
    });

    final DialogResult result = await _showProductSavedDialog(savedProduct);
    if (result == DialogResult.Yes) {
      return;
    }

    if (result == DialogResult.No) {
      Navigator.pop(context);
      return;
    } else if (result == DialogResult.DoneTagging) {
      // mark all source landings done
      for (final Landing landing in _sourceLandings) {
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

  bool _hasChanged() {
    return _tagCodeController.text.isNotEmpty;
  }

  Future<bool> get onWillPop async {
    // Have things changed since the initial state?
    final bool changed = _hasChanged();

    // If there are changes warn the user before navigating away
    if (changed) {
      final bool confirmed = await showDialog<bool>(
        context: _scaffoldKey.currentContext,
        builder: (_) => const WestlakeConfirmDialog(
          'Cancel',
          'Your unsaved changes will be lost. Are you sure you want to cancel creating this product tag?',
        ),
      );

      if (confirmed != true) {
        return false;
      }
    }

    return true;
  }

  Widget _productSavedDialog(Product product) {

    final String tagId = 'Tag ID: ${product.tagCode}';
    final String productType = 'Product type: ${product.productType.name}';

    return WestlakeDialog(
      title: 'Product Created',
      actions: <Widget>[
        WestlakeDialogOption(text: 'Yes', onPressed: _onPressDialogYes),
        WestlakeDialogOption(text: 'No', onPressed: _onPressDialogNo),
        WestlakeDialogOption(text: 'Completed', onPressed: _onPressDialogDone),
      ],
      content: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tagId,
              style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              productType,
              style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              'Do you want to create another product?',
              style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<DialogResult> _showProductSavedDialog(Product product) {
    return showDialog<DialogResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _productSavedDialog(product),
    );
  }

  Widget _quantityTextInput() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WestlakeTextInput(
            label: 'Quantity',
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
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Sources',
            style: TextStyle(fontSize: 20, color: OlracColours.fauxPasBlue),
          ),
          Column(
            children: _sourceLandings
                .map<Widget>(
                  (Landing sl) => Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: OlracColours.fauxPasBlue[300]))),
                    child: SourceLandingInfo(landing: sl),
                    height: 80,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _tagCodeInput() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WestlakeTextInput(
            label: 'Tag code',
            controller: _tagCodeController,

            validator: (t) => t,
          ),
//          TextFormField(
//            controller: _tagCodeController,
//            textCapitalization: TextCapitalization.words,
//            autocorrect: false,
//            style: const TextStyle(fontSize: 30),
//            decoration: const InputDecoration(
//              labelText: 'Tag code',
//              labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//              helperText: 'Hold tag infront of reader to scan',
//            ),
//            onFieldSubmitted: (t) {},
//            onChanged: (String enteredText) {
//              setState(() {
//                _tagCode = enteredText;
//              });
//            },
//            validator: (t) => t,
//          ),
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
                      height: packagingType.name.toLowerCase() == 'ring' ? 20 : 30,
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

  StripButton get _saveButton => StripButton(
        icon: Icon(Icons.save, color: Colors.white),
        labelText: 'Save',
        color: OlracColours.ninetiesGreen,
        onPressed: _onPressSaveButton,
      );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => await onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: const Text('Tag Product')),
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
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: _productTypeDropdown(),
                    ),

                    // Packaging
                    Container(padding: const EdgeInsets.symmetric(horizontal: 15), child: _packagingTypeDropdown()),

                    // Quantity
                    Container(padding: const EdgeInsets.symmetric(horizontal: 15), child: _quantityTextInput()),

                    // Tag code
                    if (_productType != null && _packagingType != null)
                      _tagCodeInput(),
                    const SizedBox(height: 10),
                    // Space for FAB
                  ],
                ),
              ),
            ),
            _saveButton
          ],
        ),
      ),
    );
  }
}
