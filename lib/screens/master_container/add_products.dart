import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/widgets/product_list_item.dart';

final ProductRepository _productRepo = ProductRepository();

Future<List<Product>> _productsAlreadyInMasterContainers() async {
  final MasterContainerRepository masterContainerRepository = MasterContainerRepository();
  final List<MasterContainer> masterContainers = await masterContainerRepository.all();

  final List<Product> allProductsInMCs = [];

  for (final MasterContainer mc in masterContainers) {
    final List<Product> mcProducts = await _productRepo.forMasterContainer(mc.id);
    allProductsInMCs.addAll(mcProducts);
  }

  return allProductsInMCs;
}

Future<List<Product>> _load(int sourceTripId) async {
  final List<Product> alreadyInMCs = await _productsAlreadyInMasterContainers();
  final List<Product> allInTrip = await _productRepo.forTrip(sourceTripId);

  // Don't show products that are already in MCs
  final List<Product> unused = allInTrip.where((Product pInTrip) {
    return alreadyInMCs.firstWhere((Product pUsed) => pInTrip.tagCode == pUsed.tagCode, orElse: () => null) == null;
  }).toList();

  return unused;
}

class AddProductsScreen extends StatefulWidget {
  final List<Product> alreadySelectedProducts;
  final int sourceTripId;

  const AddProductsScreen({this.alreadySelectedProducts = const [], @required this.sourceTripId})
      : assert(sourceTripId != null);

  @override
  AddProductsScreenState createState() => AddProductsScreenState(alreadySelectedProducts);
}

class AddProductsScreenState extends State<AddProductsScreen> {
  final List<Product> _alreadySelectedProducts;

  List<Product> _products = <Product>[];
  List<Product> _selectedProducts = <Product>[];

  AddProductsScreenState(this._alreadySelectedProducts);

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
    return const Center(
      child: Text('No eligible tags in this trip'),
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
          isSelectable: true,
          isSelected: _selectedProducts.contains(product),
        );
      },
    );
  }

  void _onPressAddSelectedStripButton() {
    Navigator.pop(context, _selectedProducts);
  }

  Widget _bottomButton() {
    return StripButton(
      icon: const Icon(Icons.add),
      color: _selectedProducts.isEmpty ? Colors.grey : OlracColours.ninetiesGreen,
      labelText: 'Add Selected',
      onPressed: _selectedProducts.isEmpty ? null : _onPressAddSelectedStripButton,
    );
  }

  Widget _clearSelectionSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        RaisedButton(
          color: OlracColours.ninetiesRed,
          child: const Text('Clear all'),
          onPressed: _clearSelected,
        ),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  Widget _body() {
    if (_products.isEmpty) {
      return _noProducts();
    }
    return Column(
      children: <Widget>[
        _clearSelectionSection(),
        Expanded(child: _productList()),
        _bottomButton(),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('Select Products'),
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
      future: _load(widget.sourceTripId),
      builder: (BuildContext _, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return const Scaffold();
        }
        _products = snapshot.data as List<Product>;

        _excludeAlreadySelected(_products);

        return Scaffold(
          appBar: _appBar(),
          body: _body(),
        );
      },
    );
  }
}