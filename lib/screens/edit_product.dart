import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/data/packaging_types.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/packaging_type.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/widgets/datetime_editor.dart';
import 'package:oltrace/widgets/location_editor.dart';
import 'package:oltrace/widgets/svg_icon.dart';
import 'package:olrac_widgets/westlake/westlake_text_input.dart';

class EditProduct extends StatefulWidget {
  final Product product;

  const EditProduct({this.product});

  @override
  _EditProductState createState() => _EditProductState(
        createDateTime: product.createdAt,
        createLocation: product.location,
        productUnits: product.productUnits,
        packagingType: product.packagingType,
        productType: product.productType,
      );
}

class _EditProductState extends State<EditProduct> {
  _EditProductState({
    this.createDateTime,
    this.createLocation,
    int productUnits,
    this.packagingType,
    this.productType,
  }) : _quantityController = TextEditingController(text: productUnits.toString());

  final TextEditingController _quantityController;

  Location createLocation;

  DateTime createDateTime;

  PackagingType packagingType;

  ProductType productType;

  Future<void> _onPressSave() async {
    final Product product = widget.product.copyWith(
      location: createLocation,
      createdAt: createDateTime,
      productType: productType,
      packagingType: packagingType,
      productUnits:  int.parse(_quantityController.text),
    );
    await ProductRepository().store(product);
    Navigator.pop(context);
  }

  Future<void> _onPressDelete() async {
    await ProductRepository().delete(widget.product.id);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget _locationEditor() {
    return LocationEditor(
      title: 'Creation Location',
      location: createLocation,
      onChanged: (Location location) => setState(() => createLocation = location),
    );
  }

  Widget _datetimeEditor() {
    return DateTimeEditor(
      title: 'Creation Date & Time',
      initialDateTime: createDateTime,
      onChanged: (Picker picker, List<int> selectedIndices) {
        setState(() {
          createDateTime = DateTime.parse(picker.adapter.toString());
        });
      },
    );
  }

  Widget _quantityEditor() {
    return WestlakeTextInput(
      label: 'Quantity',
      controller: _quantityController
    );
  }

  Widget _packagingTypeEditor() {
    return ModelDropdown<PackagingType>(
      label: 'Packaging Type',
      selected: packagingType,
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
      onChanged: (PackagingType pt) {
        setState(() => packagingType = pt);
      },
    );
  }

  Widget _productTypeEditor() {
    return ModelDropdown<ProductType>(
      selected: productType,
      label: 'Product Type',
      onChanged: (ProductType pt) => setState(() => productType = pt),
      items: productTypes.map<DropdownMenuItem<ProductType>>((ProductType productType) {
        return DropdownMenuItem<ProductType>(
          value: productType,
          child: Text(productType.name),
        );
      }).toList(),
    );
  }

  Widget _body() {
    return Builder(builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          children: [
            _locationEditor(),
            _datetimeEditor(),
            _quantityEditor(),
            _packagingTypeEditor(),
            _productTypeEditor(),
          ].map((e) => Padding(padding: const EdgeInsets.all(8), child: e)).toList(),
        ),
      );
    });
  }

  List<StripButton> _bottomButtons() {
    final StripButton saveButton = StripButton(
      onPressed: _onPressSave,
      labelText: 'Save',
      icon: const Icon(
        Icons.save,
        color: Colors.white,
      ),
      color: OlracColours.ninetiesGreen,
    );

    final StripButton deleteButton = StripButton(
      onPressed: _onPressDelete,
      labelText: 'Delete',
      icon: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      color: OlracColours.ninetiesRed,
    );

    return [
      saveButton,
      deleteButton,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WestlakeScaffold(
      title: 'Edit Product',
      bottomButtons: _bottomButtons(),
      body: (BuildContext context, _) {
        return _body();
      },
    );
  }
}
