import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/fishing_method_type.dart';
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
import 'package:oltrace/screens/haul/haul_info.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/product_list_item.dart';

final _landingRepo = LandingRepository();
final _haulRepo = HaulRepository();
final _tripRepo = TripRepository();
final _productRepo = ProductRepository();

Future<Map<String, dynamic>> _load(int haulId) async {
  final Haul haul = await _haulRepo.find(haulId);
  final Trip activeTrip = await _tripRepo.getActive();
  final bool isPartOfActiveTrip = activeTrip?.id == haul.tripId;
  final List<Landing> landings = await _landingRepo.forHaul(haul.id);
  final Trip parentTrip = await _tripRepo.find(haul.tripId);

  final List<Product> flatProducts = [];

  for (final Landing landing in landings) {
    final List<Product> products = await _productRepo.forLanding(landing.id);
    for (final Product product in products) {
      final List foundProds = flatProducts.where((Product p) => p.id == product.id).toList();
      if (foundProds.isEmpty) {
        flatProducts.add(product);
      }
    }
  }

  return {
    'haul': haul,
    'products': flatProducts,
    'isActiveTrip': isPartOfActiveTrip,
    'parentTripUploaded': parentTrip.isUploaded
  };
}

enum SpeciesSelectMode { Single, Bulk, Cancel }

class HaulScreen extends StatefulWidget {
  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;
  final int listIndex;
  final int haulId;
  final LocationProvider _locationProvider = LocationProvider();

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

  Haul _haul;
  List<Product> _products;
  List<Landing> _selectedLandings = [];
  bool _showProductList = false;
  bool _isActiveTrip;
  bool _parentTripUploaded;

  void _onPressShowProductListSwitch(bool value) {
    setState(() {
      _showProductList = value;
    });
  }

  Future<void> _onPressProductListItem(int productId) async {
    await Navigator.pushNamed(
      _scaffoldKey.currentContext,
      '/product',
      arguments: {'productId': productId},
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
  }

  Future<void> _onPressCancelHaul() async {
    final bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => const WestlakeConfirmDialog(
        'Cancel Haul',
        'Are you sure you want to cancel the haul? The haul will be removed. '
            'This action cannot be undone.',
      ),
    );

    if (confirmed != null && confirmed) {
      await _haulRepo.delete(widget.haulId);
      Navigator.pop(_scaffoldKey.currentContext);
    }
  }

  Future<void> _onPressEndHaul() async {
    final bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => WestlakeConfirmDialog(
        Messages.endHaulTitle(_haul),
        Messages.endHaulDialogContent(_haul),
      ),
    );

    if (confirmed == true) {
      final Location location = await widget._locationProvider.location;

      final endedHaul = _haul.copyWith(
        endedAt: DateTime.now(),
        endLocation: location,
      );

      await _haulRepo.store(endedHaul);
      setState(() {});
    }
  }

  void _showFirstEndDynamicHaulSnackbar() {
    showTextSnackBar(_scaffoldKey, Messages.LANDING_FIRST_END_DYNAMIC_HAUL);
  }

  bool _isDynamicAndNotEnded() => _haul.endedAt == null && _haul.fishingMethod.type == FishingMethodType.Dynamic;

  Future<void> _onPressAddBulkLanding() async {
    if (_isDynamicAndNotEnded()) {
      _showFirstEndDynamicHaulSnackbar();
      return;
    }
    widget.sharedPrefs.setBool('bulkMode', true);
    await Navigator.pushNamed(context, '/create_landing', arguments: _haul);
  }

  Future<void> _onPressAddLandingButton() async {
    if (_isDynamicAndNotEnded()) {
      _showFirstEndDynamicHaulSnackbar();
      return;
    }

    widget.sharedPrefs.setBool('bulkMode', false);
    await Navigator.pushNamed(context, '/create_landing', arguments: _haul);
  }

  Future<void> _onPressTagProduct() async {
    if (_selectedLandings.isEmpty) {
      showTextSnackBar(_scaffoldKey, Messages.LANDING_FIRST_SELECT_SPECIES);
      return;
    }
    await Navigator.pushNamed(context, '/create_product', arguments: {'haul': _haul, 'landings': _selectedLandings});
  }

  bool _landingIsSelected(Landing landing) {
    final Landing found = _selectedLandings.singleWhere((l) => l.id == landing.id, orElse: () => null);
    return found != null;
  }

  void _onLongPressLanding(int indexPressed) {
    final landing = _haul.landings.singleWhere((l) => l.id == indexPressed);
    setState(() {
      if (_landingIsSelected(landing)) {
        _selectedLandings.removeWhere((l) => l.id == landing.id);
      } else {
        _selectedLandings.add(landing);
      }
    });
  }

  void _onPressClearAllButton() {
    setState(() {
      _selectedLandings = [];
    });
  }

  Widget _toggleListButton() {
    return StripButton(
      color: OlracColours.olspsDarkBlue,
      labelText: _showProductList ? 'Show Species List' : 'Show Tags List',
      onPressed: () => _onPressShowProductListSwitch(!_showProductList),
    );
  }

  Widget _clearSelectedButton() {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: RaisedButton(
        color: OlracColours.ninetiesRed,
        child: Text(
          'Clear All',
          style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white),
        ),
        onPressed: _onPressClearAllButton,
      ),
    );
  }

  Widget _listsSection(List<Landing> landings) {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(flex: 2, child: _listsLabel(_showProductList ? 'Tag List' : 'Species List')),
                  if (_selectedLandings.isNotEmpty) Container(width: 200,child: _clearSelectedButton()),
                  if (_products.isNotEmpty && _selectedLandings.isEmpty) Container(width: 200,child: _toggleListButton()),
                ],
              ),
            ),
            if (_showProductList) _productList() else _landingsList(landings),
          ],
        ),
      ),
    );
  }

  Widget _productList() {
    if (_products.isEmpty) {
      return _noProducts();
    }
    final List<Widget> items = _products
        .map((Product product) => ProductListItem(
              product: product,
              onPressed: () async => await _onPressProductListItem(product.id),
            ))
        .toList();
    return Expanded(child: ListView(children: items));
  }

  Widget _landingsList(List<Landing> landings) {
    if (landings.isEmpty) {
      return _noLandings();
    }
    int landingIndex = landings.length;

    final List<LandingListItem> listLandings = landings.reversed
        .map(
          (Landing landing) => LandingListItem(
            isSelectable: _isActiveTrip,
            isSelected: _landingIsSelected(landing),
            landing: landing,
            onLongPress: () => _onLongPressLanding(landing.id),
            onPressed: (int indexPressed) async => await _onPressLandingListItem(landing.id, indexPressed),
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

  Widget _addSingleLandingButton() => StripButton(
        icon: const Icon(
          Icons.add_circle,
          color: Colors.white
        ),
        color: OlracColours.ninetiesGreen,
        labelText: 'Single',
        onPressed: _onPressAddLandingButton,
      );

  Widget _addBulkLandingButton() => StripButton(
        icon: const Icon(
          Icons.add_circle,
          color: Colors.white
        ),
        color: OlracColours.olspsDarkBlue,
        labelText: 'Bulk',
        onPressed: _onPressAddBulkLanding,
      );

  Widget _tagProductButton() => StripButton(
        icon: const Icon(
          Icons.add_circle,
          color: Colors.white
        ),
        color: _selectedLandings.isNotEmpty ? OlracColours.fauxPasBlue : Colors.grey,
        labelText: 'Tag',
        onPressed: _onPressTagProduct,
      );

  Widget _bottomButtons() {
    return Column(
      children: [
        Text('Add / Tag catches',style: Theme.of(context).textTheme.caption),
        Row(
          children: <Widget>[
            if (_selectedLandings.isEmpty) Expanded(child: _addSingleLandingButton()),
            if (_selectedLandings.isEmpty) Expanded(child: _addBulkLandingButton()),
            if (!_showProductList) Expanded(child: _tagProductButton()),
          ],
        ),
      ],
    );
  }

  Widget _noLandings() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          'No species in this haul',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _noProducts() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: const Text(
          'No tags in this haul',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _listsLabel(String text) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, color: OlracColours.fauxPasBlue),
      ),
    );
  }

  Text _title() {
    final int numberSelected = _selectedLandings.length;

    if (_selectedLandings.isEmpty) {
      return Text(_haul.fishingMethod.name);
    }

    return Text('$numberSelected selected');
  }

  Widget _appBarLeading() => BackButton(
        onPressed: () {
          Navigator.pop(_scaffoldKey.currentContext);
        },
      );

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
          return const Scaffold();
        }

        _haul = snapshot.data['haul'];
        _products = snapshot.data['products'];
        _isActiveTrip = snapshot.data['isActiveTrip'];
        _parentTripUploaded = snapshot.data['parentTripUploaded'];

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: _title(),
            leading: _appBarLeading(),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                HaulInfo(
                  haul: _haul,
                  onPressEndHaul: _onPressEndHaul,
                  onPressCancelHaul: _onPressCancelHaul,
                  listIndex: widget.listIndex,
                  isActiveHaul: _haul.endedAt == null,
                  isTripUploaded: _parentTripUploaded,
                ),
                _listsSection(_haul.landings),
                if (_isActiveTrip) _bottomButtons(),
              ],
            ),
          ),
        );
      },
    );
  }
}
