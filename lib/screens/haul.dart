import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
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
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/product_list_item.dart';
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

  List<Product> flatProducts = [];

  for (Landing landing in landings) {
    final List<Product> products = await _productRepo.forLanding(landing.id);
    for (Product product in products) {
      List foundProds = flatProducts.where((Product p) => p.id == product.id).toList();
      if (foundProds.length == 0) {
        flatProducts.add(product);
      }
    }
    landingsWithProducts.add(landing.copyWith(products: products));
  }

  return {
    'haul': haul.copyWith(landings: landingsWithProducts),
    'products': flatProducts,
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

  Haul _haul;
  List<Product> _products;
  List<Landing> _selectedLandings = [];
  bool _showProductList = false;

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
    setState(() {});
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
      showTextSnackBar(_scaffoldKey, 'Haul was ended', duration: Duration(seconds: 1));
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
    setState(() {});
  }

  Future<void> _onPressAddLandingButton() async {
    if (_isDynamicAndNotEnded()) {
      _showFirstEndDynamicHaulSnackbar();
      return;
    }

    widget.sharedPrefs.setBool('bulkMode', false);
    await Navigator.pushNamed(context, '/create_landing', arguments: _haul);
    setState(() {});
  }

  Future<void> _onPressTagProduct() async {
    if (_selectedLandings.isEmpty) {
      showTextSnackBar(_scaffoldKey, Messages.LANDING_FIRST_SELECT_SPECIES);
      return;
    }
    await Navigator.pushNamed(context, '/create_product', arguments: {'haul': _haul, 'landings': _selectedLandings});
    setState(() {
      _selectedLandings = [];
    });
  }

  bool _landingIsSelected(Landing landing) {
    final Landing found = _selectedLandings.singleWhere((l) => l.id == landing.id, orElse: () => null);
    return found == null ? false : true;
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

  Widget _toggleListButton() {
    return Container(
      margin: EdgeInsets.only(right: 5),
      child: RaisedButton(
        child: Text(_showProductList ? 'Show Species List' : 'Show Tags List'),
        onPressed: () => _onPressShowProductListSwitch(!_showProductList),
      ),
    );
  }

  Widget _listsSection(List<Landing> landings) {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _listsLabel(_showProductList ? 'Tag List' : 'Species List'),
                if (_products.length != 0) _toggleListButton(),
              ],
            ),
            _showProductList ? _productList() : _landingsList(landings),
          ],
        ),
      ),
    );
  }

  Widget _productList() {
    if (_products.length == 0) {
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
    if (landings.length == 0) {
      return _noLandings();
    }
    int landingIndex = landings.length;

    final List<LandingListItem> listLandings = landings.reversed
        .map(
          (Landing landing) => LandingListItem(
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
        icon: Icon(
          Icons.add_circle,
          color: Colors.white,
        ),
        color: Colors.green,
        labelText: 'Single',
        onPressed: _onPressAddLandingButton,
      );

  Widget _addBulkLandingButton() => StripButton(
        icon: Icon(
          Icons.add_box,
          color: Colors.white,
        ),
        color: olracDarkBlue,
        labelText: 'Bulk',
        onPressed: _onPressAddBulkLanding,
      );

  Widget _tagProductButton() => StripButton(
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        color: _selectedLandings.isNotEmpty ? olracBlue : Colors.grey,
        labelText: 'Tag',
        onPressed: _onPressTagProduct,
      );

  Widget _bottomButtons() {
    return Row(
      children: <Widget>[
        Expanded(child: _addSingleLandingButton()),
        Expanded(child: _addBulkLandingButton()),
        if (!_showProductList) Expanded(child: _tagProductButton()),
      ],
    );
  }

  Widget _noLandings() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(
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
        child: Text(
          'No tags in this haul',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _listsLabel(String text) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: 22, color: olracBlue),
      ),
    );
  }

  Text _title() {
    final int numberSelected = _selectedLandings.length;

    if (_selectedLandings.length == 0) {
      return Text(_haul.fishingMethod.name);
    }

    return Text('$numberSelected selected');
  }

  Widget _appBarLeading() => _selectedLandings.length != 0
      ? IconButton(
          onPressed: () {
            setState(() {
              _selectedLandings = [];
            });
          },
          icon: Icon(Icons.cancel, color: Colors.white),
        )
      : BackButton(
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
          return Scaffold();
        }

        _haul = snapshot.data['haul'];
        _products = snapshot.data['products'];

        final bool isActiveTrip = snapshot.data['isActiveTrip'];

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
                ),
                _listsSection(_haul.landings),
                isActiveTrip ? _bottomButtons() : Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}
