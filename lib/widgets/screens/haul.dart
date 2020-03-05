import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/screens/add_source_landing.dart';
import 'package:oltrace/widgets/screens/haul/haul_info.dart';
import 'package:oltrace/widgets/strip_button.dart';

final _landingRepo = LandingRepository();
final _haulRepo = HaulRepository();
final _tripRepo = TripRepository();
final _productRepo = ProductRepository();

Future<Map<String, dynamic>> _load(int haulId) async {
  final Haul haul = await _haulRepo.find(haulId);
  final Trip activeTrip = await _tripRepo.getActive();
  final bool isActiveTrip = activeTrip?.id == haul.tripId;
  final List<Landing> landings = await _landingRepo.forHaul(haul);
  final List<Landing> landingsWithProducts = [];
  for (Landing landing in landings) {
    final List<Product> products = await _productRepo.forLanding(landing.id);
    landingsWithProducts.add(landing.copyWith(products: products));
  }
  return {
    'haul': haul.copyWith(landings: landingsWithProducts),
    'isActiveTrip': isActiveTrip,
  };
}

enum SpeciesSelectMode { Single, Bulk, Cancel }

class HaulScreen extends StatefulWidget {
  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;
  final int listIndex;
  final int haulId;
  final _locationProvider = LocationProvider();

  HaulScreen({
    @required this.haulId,
    @required this.listIndex,
  })  : assert(haulId != null),
        assert(listIndex != null);

  @override
  State<StatefulWidget> createState() {
    return HaulScreenState();
  }
}

class HaulScreenState extends State<HaulScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Haul haul;

  Widget _addLandingButton(Haul haul, BuildContext context) => StripButton(
        centered: true,
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        color: Colors.green,
        labelText: 'Species',
        onPressed: () async => await _onPressAddLandingButton(haul, context),
      );

  Widget _addProductButton(Haul haul, BuildContext context) => StripButton(
        centered: true,
        icon: Icon(
          Icons.local_offer,
          color: Colors.white,
        ),
        color: olracBlue,
        labelText: 'Tag',
        onPressed: () async => await _onPressAddProductButton(haul, context),
      );

  Widget _bottomButtons(Haul haul) => Builder(
        builder: (context) => Row(
          children: <Widget>[
            Expanded(child: _addLandingButton(haul, context)),
            Expanded(child: _addProductButton(haul, context)),
          ],
        ),
      );

  Widget _noLandings() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          'No sharks',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _landingsSection(List<Landing> landings) {
    if (landings.length == 0) {
      return _noLandings();
    }

    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            _landingsLabel(landings),
            _landingsList(landings),
          ],
        ),
      ),
    );
  }

  Future<void> _onPressLandingListItem(int landingId, int landingIndex) async {
    assert(landingId != null);
    assert(landingIndex != null);

    await Navigator.pushNamed(
      _scaffoldKey.currentContext,
      '/landing',
      arguments: {
        'landingId': landingId,
        'listIndex': landingIndex,
      },
    );

    setState(() {});
  }

  Widget _landingsList(List<Landing> landings) {
    int landingIndex = landings.length;

    final List<LandingListItem> listLandings = landings.reversed
        .map(
          (Landing landing) => LandingListItem(
            landing: landing,
            onPressed: (int indexPressed) async =>
                await _onPressLandingListItem(landing.id, indexPressed),
            listIndex: landingIndex--,
          ),
        )
        .toList();

    return Expanded(
      child: ListView(
        children: listLandings,
      ),
    );
  }

  Future<void> _onPressAddLandingButton(Haul haul, BuildContext context) async {
    final bool bulkMode = await _showAddSpeciesDialog(context);
    if (bulkMode == null) {
      return;
    }
    widget.sharedPrefs.setBool('bulkMode', bulkMode);
    await Navigator.pushNamed(context, '/create_landing', arguments: haul);
    setState(() {});
  }

  Future<bool> _showAddSpeciesDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        actions: <Widget>[
          FlatButton(
            child: Text('Single'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: Text('Bulk'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
        title: Text('Add Species'),
        content: Text('How do you want to add species?'),
      ),
    );
  }

  Future<SpeciesSelectMode> _showAddProductDialog(BuildContext context) async {
    return await showDialog<SpeciesSelectMode>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        actions: <Widget>[
          FlatButton(
            child: Text('Single'),
            onPressed: () => Navigator.of(_).pop(SpeciesSelectMode.Single),
          ),
          FlatButton(
            child: Text('Mixed'),
            onPressed: () => Navigator.of(_).pop(SpeciesSelectMode.Bulk),
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(_).pop(SpeciesSelectMode.Cancel),
          ),
        ],
        title: Text('Add Tag'),
        content: Text('What product do you want to tag?'),
      ),
    );
  }

  Future<void> _onPressAddProductButton(Haul haul, context) async {
//    SpeciesSelectMode selection = await _showAddProductDialog(context);
//    if (selection == SpeciesSelectMode.Cancel) {
//      return;
//    }

    final List<Landing> selectedLandings = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSourceLandingsScreen(
          alreadySelectedLandings: [],
          selectionMode: SpeciesSelectMode.Single,
          sourceHaul: haul,
        ),
      ),
    );
    if (selectedLandings == null) {
      return;
    }
    await Navigator.pushNamed(context, '/create_product',
        arguments: {'haul': haul, 'landings': selectedLandings});
  }

  Widget _landingsLabel(List<Landing> landings) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        'Species List',
        style: TextStyle(fontSize: 30, color: olracBlue),
      ),
    );
  }

  Future<void> _onPressCancelHaul() async {
    bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => ConfirmDialog(
          'Cancel Haul',
          ('Are you sure you want to cancel the haul? The haul will be removed. '
              'This action cannot be undone.')),
    );

    if (confirmed != null && confirmed) {
      await _haulRepo.delete(widget.haulId);
      Navigator.pop(_scaffoldKey.currentContext);
    }
  }

  Future<void> _onPressEndHaul() async {
    bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => ConfirmDialog(
        'End Haul',
        'Are you sure you want to end the haul? You will not be able to continue later.',
      ),
    );

    if (confirmed == true) {
      final Location location = await widget._locationProvider.location;

      final endedHaul = haul.copyWith(
        endedAt: DateTime.now(),
        endLocation: location,
      );

      await _haulRepo.store(endedHaul);
      Navigator.pop(_scaffoldKey.currentContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(widget.haulId),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }

        haul = snapshot.data['haul'];

        final bool isActiveTrip = snapshot.data['isActiveTrip'];

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(haul.fishingMethod.name),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                HaulInfo(
                  haul: haul,
                  onPressEndHaul: _onPressEndHaul,
                  onPressCancelHaul: _onPressCancelHaul,
                  listIndex: widget.listIndex,
                  isActiveHaul: haul.endedAt == null,
                ),
                _landingsSection(haul.landings),
                isActiveTrip ? _bottomButtons(haul) : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
