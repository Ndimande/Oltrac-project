import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/landing/products_list.dart';
import 'package:oltrace/screens/landing/species_information.dart';
import 'package:oltrace/widgets/shark_info_card.dart';

final _landingRepo = LandingRepository();
final _tripRepository = TripRepository();
final _productRepository = ProductRepository();

Future<Map<String, dynamic>> _load(int landingId) async {
  final Landing landing = await _landingRepo.find(landingId);
  final Haul haul = await HaulRepository().find(landing.haulId);
  final Trip trip = await _tripRepository.find(haul.tripId);
  final Trip activeTrip = await _tripRepository.getActive();
  final bool isActiveTrip = activeTrip?.id == haul.tripId;

  return {
    'landing': landing,
    'isActiveTrip': isActiveTrip,
    'tripUploaded': trip.isUploaded,
  };
}

class LandingScreen extends StatefulWidget {
  final int landingId;
  final int listIndex;

  const LandingScreen({
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
  bool _isActiveTrip;
  bool _tripIsUploaded;

  final _landingRepository = LandingRepository();

  Future<void> _onPressTagProduct() async {
    final Haul haul = await HaulRepository().find(_landing.haulId);

    final List<Landing> landings = await _landingRepository.forHaul(haul.id);
    final List<Landing> withProducts = [];
    for (final Landing landing in landings) {
      final List<Product> products = await _productRepository.forLanding(landing.id);
      withProducts.add(landing.copyWith(products: products));
    }
    // add prods
    await Navigator.pushNamed(_scaffoldKey.currentContext, '/create_product', arguments: {
      'landings': [_landing],
      'haul': haul.copyWith(landings: withProducts),
      'tripIsUploaded': true,
    });
  }

  Future<void> _onPressDelete() async {
    final bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => const WestlakeConfirmDialog('Delete Species', 'Are you sure you want to delete this species?'),
    );
    if (!confirmed) {
      return;
    }
    await _landingRepository.delete(widget.landingId);

    showTextSnackBar(_scaffoldKey, 'Species deleted');

    await Future.delayed(const Duration(seconds: 1));
    Navigator.pop(_scaffoldKey.currentContext);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _onPressEdit() async {
    await Navigator.pushNamed(_scaffoldKey.currentContext, '/edit_landing', arguments: _landing);
  }

  Future<void> _onPressDoneTagging() async {
    if (_landing.products.isEmpty && !_landing.doneTagging) {
      showTextSnackBar(_scaffoldKey, 'You must tag at least one');
      return;
    }
    final bool doneTagging = !_landing.doneTagging;
    await _landingRepo.store(_landing.copyWith(doneTagging: doneTagging));
    setState(() {});
    if (doneTagging == true) {
      Navigator.pop(context);
    }
  }

  Widget _doneTaggingButton() {
    return StripButton(
      color: OlracColours.fauxPasBlue,
      labelText: _landing.doneTagging ? 'Continue Tagging' : 'Done Tagging',
      icon: Icon(
        _landing.doneTagging ? Icons.edit : Icons.check_circle,
        color: Colors.white,
      ),
      onPressed: _onPressDoneTagging,
    );
  }

  Widget _tagProductButton() {
    if (_landing.doneTagging == true) {
      return Container();
    }

    return StripButton(
      color: OlracColours.ninetiesGreen,
      labelText: 'Tag Product',
      icon: const Icon(Icons.local_offer, color: Colors.white),
      onPressed: () async => await _onPressTagProduct(),
    );
  }

  Widget _landingButtons() {
    return Row(
      children: <Widget>[_deleteButton(_onPressDelete), _editButton(_onPressEdit)],
    );
  }

  Widget _bottomButtons() {
    final items = <Widget>[];

    if (!_landing.doneTagging) {
      items.add(_tagProductButton());
    }

//    if (_landing.products.isNotEmpty) {
      items.add(_doneTaggingButton());
//    }

    return Row(children: items.map((i) => Expanded(child: i)).toList());
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Container(
                    color: OlracColours.fauxPasBlue[50],
                    child: SharkInfoCard(landing: _landing, listIndex: widget.listIndex),
                  ),
                  if (!_tripIsUploaded) _landingButtons(),
                  ProductsList(products: _landing.products),
                  SpeciesInformation(landing: _landing),
                ],
              ),
            ),
          ),
        ),
        if (_isActiveTrip) _bottomButtons(),
      ],
    );
  }

  Widget _appBar() {
    return AppBar(
      title: Text(_landing.isBulk ? '${_landing.species.englishName} (Bulk bin)' : _landing.species.englishName),
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
          return const Scaffold();
        }

        final Map data = snapshot.data;
        _isActiveTrip = data['isActiveTrip'];
        _landing = data['landing'];
        _tripIsUploaded = data['tripUploaded'] as bool;
        return Scaffold(
          key: _scaffoldKey,
          appBar: _appBar(),
          body: _body(),
        );
      },
    );
  }
}

Widget _deleteButton(onPressed) => Expanded(
      child: StripButton(
        onPressed: onPressed,
        labelText: 'Delete',
        color: OlracColours.ninetiesRed,
        icon: const Icon(Icons.delete, color: Colors.white),
      ),
    );

Widget _editButton(onPressed) => Expanded(
      child: StripButton(
        onPressed: onPressed,
        labelText: 'Edit',
        color: OlracColours.fauxPasBlue,
        icon: const Icon(Icons.edit, color: Colors.white),
      ),
    );
