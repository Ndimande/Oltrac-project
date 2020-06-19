import 'package:flutter/material.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/widgets/master_container_info.dart';
import 'package:oltrace/widgets/product_list_item.dart';
import 'package:oltrace/widgets/sharktrace_qr_image.dart';

final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();

Future<MasterContainer> _load(int id) async {
  final ProductRepository _productRepository = ProductRepository();

  final MasterContainer masterContainer = await _masterContainerRepo.find(id);

  final List<Product> products = await _productRepository.forMasterContainer(id);
  return masterContainer.copyWith(products: products);
}

class MasterContainerScreen extends StatefulWidget {
  final int masterContainerId;
  final int masterContainerIndex;

  const MasterContainerScreen({@required this.masterContainerId, this.masterContainerIndex}) : assert(masterContainerId != null);

  @override
  _MasterContainerScreenState createState() => _MasterContainerScreenState();
}

class _MasterContainerScreenState extends State<MasterContainerScreen> {
  MasterContainer masterContainer;

  Widget _qrCode() {
    final int nProducts = masterContainer.products.length;

    return SharkTraceQrImage(
      data: masterContainer.tagCode,
      title: masterContainer.tagCode,
      subtitle: 'Master Container ($nProducts)',
    );
  }

  Widget _productList() {
    if (masterContainer.products.isEmpty) {
      return const Text('No Source products');
    }
    return Column(
      children: masterContainer.products.map<Widget>((Product product) {
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

  Future<void> _onPressDelete() async {
    // Are you sure?
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const WestlakeConfirmDialog('Delete', 'Are you sure?'),
    );

    if(!confirmed) {
      return;
    }

    await _masterContainerRepo.delete(masterContainer.id);

    Navigator.pop(context);
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          MasterContainerInfo(masterContainer: masterContainer,indexNumber: widget.masterContainerIndex,onPressDelete: _onPressDelete,),
          _qrCode(),
          _productList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(widget.masterContainerId),
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return const Scaffold();
        }
        masterContainer = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Master Container'),
          ),
          body: _body(),
        );
      },
    );
  }
}
