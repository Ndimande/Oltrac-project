import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart' as util;
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/widgets/sharktrack_qr_image.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/product_list_item.dart';

final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();
final ProductRepository _productRepository = ProductRepository();

Future<MasterContainer> _load(int id) async {
  final MasterContainer masterContainer = await _masterContainerRepo.find(id);

  final List<Product> products = await _productRepository.forMasterContainer(id);
  return masterContainer.copyWith(products: products);
}

class MasterContainerScreen extends StatefulWidget {
  final int masterContainerId;

  MasterContainerScreen({@required this.masterContainerId}) : assert(masterContainerId != null);

  @override
  _MasterContainerScreenState createState() => _MasterContainerScreenState();
}

class _MasterContainerScreenState extends State<MasterContainerScreen> {
  MasterContainer masterContainer;

  Widget _qrCode() {
    final int nProducts = masterContainer.products.length;

    return SharkTrackQrImage(
      data: masterContainer.tagCode,
      title: masterContainer.tagCode,
      subtitle: 'Master Container ($nProducts)',
    );
  }

  Widget _details() {
    return Container(
      color: OlracColours.olspsBlue[50],
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            masterContainer.tagCode,
            style: TextStyle(fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                util.friendlyDateTime(masterContainer.createdAt),
                style: TextStyle(fontSize: 18),
              ),
              LocationButton(location: masterContainer.location),
            ],
          ),
        ],
      ),
    );
  }

  Widget _productList() {
    if (masterContainer.products.length == 0) {
      return Text('No Source products');
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

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _details(),
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
          return Scaffold();
        }
        masterContainer = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text('Master Container'),
          ),
          body: _body(),
        );
      },
    );
  }
}
