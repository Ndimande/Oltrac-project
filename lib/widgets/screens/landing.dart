import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/landing/landing_details.dart';
import 'package:oltrace/widgets/screens/landing/products_list.dart';
import 'package:oltrace/widgets/shark_info_card.dart';
import 'package:oltrace/widgets/strip_button.dart';

const double rowFontSize = 18;
final _landingRepo = LandingRepository();
final _tripRepository = TripRepository();
final _productRepository = ProductRepository();

Future<Map<String, dynamic>> _load(int landingId) async {
  final Landing landing = await _landingRepo.find(landingId);
  final Haul haul = await HaulRepository().find(landing.haulId);

  final Trip activeTrip = await _tripRepository.getActive();
  final bool isActiveTrip = activeTrip?.id == haul.tripId;
  final List<Product> products = await _productRepository.forLanding(landingId);

  return {
    'landing': landing.copyWith(products: products),
    'isActiveTrip': isActiveTrip,
  };
}

class LandingScreen extends StatefulWidget {
  final int landingId;
  final int listIndex;

  LandingScreen({
    @required this.landingId,
    @required this.listIndex,
  })  : assert(landingId != null),
        assert(listIndex != null);

  @override
  State<StatefulWidget> createState() {
    return LandingScreenState();
  }
}

class LandingScreenState extends State<LandingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Landing _landing;

  final _landingRepository = LandingRepository();

  Future<void> _onPressTagProduct(Landing landing) async {
    final Haul haul = await HaulRepository().find(landing.haulId);

    await Navigator.pushNamed(_scaffoldKey.currentContext, '/create_product', arguments: {
      'landings': [landing],
      'haul': haul
    });
  }

  Widget get deleteButton => Expanded(
        child: StripButton(
          centered: true,
          onPressed: _onPressDelete,
          labelText: 'Delete',
          color: Colors.red,
          icon: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      );

  Widget get editButton => Expanded(
        child: StripButton(
          centered: true,
          onPressed: _onPressEdit,
          labelText: 'Edit',
          color: olracBlue,
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
      );

  Widget actionButtons() {
    return Row(
      children: <Widget>[deleteButton, editButton],
    );
  }

  Future<void> _onPressDelete() async {
    bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) =>
          ConfirmDialog('Delete Species', 'Are you sure you want to delete this species?'),
    );
    if (!confirmed) {
      return;
    }
    await _landingRepository.delete(widget.landingId);

    showTextSnackBar(_scaffoldKey, 'Species deleted');

    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(_scaffoldKey.currentContext);
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _onPressEdit() async {
    await Navigator.pushNamed(_scaffoldKey.currentContext, '/edit_landing', arguments: _landing);
    setState(() {});
  }

  Widget tagProductButton(Landing landing) {
    if (landing.doneTagging == true) {
      return Container();
    }

    return StripButton(
      color: Colors.green,
      centered: true,
      labelText: 'Tag Product',
      icon: Icon(
        Icons.local_offer,
        color: Colors.white,
      ),
      onPressed: () async => await _onPressTagProduct(landing),
    );
  }

  Widget noProducts() {
    return Text(
      'No product tags yet',
      style: TextStyle(fontSize: 16),
    );
  }

  Widget _doneTaggingSwitch(bool isActiveTrip) {
    if (!isActiveTrip) {
      return Container();
    }
    return Row(
      children: <Widget>[
        Text('Done'),
        Switch(
          activeColor: Colors.white,
          value: _landing.doneTagging ?? false,
          onChanged: (bool value) async {

            await _landingRepo.store(_landing.copyWith(doneTagging: value));
            setState(() {});
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(widget.landingId),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }
        final Map data = snapshot.data;
        final bool isActiveTrip = data['isActiveTrip'];
        _landing = data['landing'];

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(_landing.individuals > 1 ? 'Bulk bin' : 'Species'),
            actions: <Widget>[_doneTaggingSwitch(isActiveTrip)],
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          color: olracBlue[50],
                          child: SharkInfoCard(
                            landing: _landing,
                            listIndex: widget.listIndex,
                          ),
                        ),
                        isActiveTrip ? actionButtons() : Container(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: LandingDetails(landing: _landing),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                        ),
                        Container(
                          child: _landing.products.length > 0
                              ? ProductsList(products: _landing.products)
                              : noProducts(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              isActiveTrip ? tagProductButton(_landing) : Container(),
            ],
          ),
        );
      },
    );
  }
}
