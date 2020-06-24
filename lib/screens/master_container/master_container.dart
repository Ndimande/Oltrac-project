import 'package:flutter/material.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/widgets/master_container_info.dart';
import 'package:oltrace/widgets/product_list_item.dart';
import 'package:oltrace/widgets/sharktrace_qr_image.dart';

final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();

Future<Map<String, dynamic>> _load(int id) async {
  final ProductRepository _productRepository = ProductRepository();
  final TripRepository _tripRepository = TripRepository();

  final MasterContainer masterContainer = await _masterContainerRepo.find(id);

  final List<Product> products = await _productRepository.forMasterContainer(id);

  final Trip trip = await _tripRepository.find(masterContainer.tripId);
  assert(trip != null);

  return {
    'masterContainer': masterContainer.copyWith(products: products),
    'tripIsUploaded': trip.isUploaded,
  };

//  return masterContainer.copyWith(products: products);
}

class MasterContainerScreen extends StatefulWidget {
  final int masterContainerId;
  final int masterContainerIndex;

  const MasterContainerScreen({@required this.masterContainerId, this.masterContainerIndex})
      : assert(masterContainerId != null);

  @override
  _MasterContainerScreenState createState() => _MasterContainerScreenState();
}

class _MasterContainerScreenState extends State<MasterContainerScreen> {
  MasterContainer _masterContainer;
  bool _tripIsUploaded;

  Widget _qrCode() {
    final int nProducts = _masterContainer.products.length;

    return SharkTraceQrImage(
      data: _masterContainer.tagCode,
      title: _masterContainer.tagCode,
      subtitle: 'Master Container ($nProducts)',
    );
  }

  Widget _productList() {
    if (_masterContainer.products.isEmpty) {
      return const Text('No Source products');
    }
    return Column(
      children: _masterContainer.products.map<Widget>((Product product) {
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

    if (!confirmed) {
      return;
    }

    await _masterContainerRepo.delete(_masterContainer.id);

    Navigator.pop(context);
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          MasterContainerInfo(
              masterContainer: _masterContainer,
              indexNumber: widget.masterContainerIndex,
              onPressDelete: _onPressDelete,
              showDeleteButton: !_tripIsUploaded),
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
        _masterContainer = snapshot.data['masterContainer'];
        _tripIsUploaded = snapshot.data['tripIsUploaded'] as bool;
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
