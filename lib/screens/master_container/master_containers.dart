import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/screens/master_container/master_container.dart';
import 'package:oltrace/screens/master_container/master_container_form.dart';
import 'package:oltrace/widgets/master_container_list_item.dart';

Future<Map<String, dynamic>> _load(int tripId) async {
  final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();
  final TripRepository _tripRepo = TripRepository();

  final List<MasterContainer> masterContainers = await _masterContainerRepo.all(where: 'trip_id = $tripId');

  final Trip trip = await _tripRepo.find(tripId);
  return <String, dynamic>{
    'masterContainers': masterContainers.reversed.toList(),
    'tripIsActive': trip.isActive,
  };
}

class MasterContainersScreen extends StatefulWidget {
  final int sourceTripId;

  const MasterContainersScreen(this.sourceTripId);

  @override
  _MasterContainersScreenState createState() => _MasterContainersScreenState();
}

class _MasterContainersScreenState extends State<MasterContainersScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MasterContainer> _masterContainers;
  bool _tripIsActive;

  Future<void> _onPressCreateStripButton() async {
    await Navigator.push(
        _scaffoldKey.currentContext,
        MaterialPageRoute(
          builder: (_) => MasterContainerFormScreen(sourceTripId: widget.sourceTripId),
        ));

    // Refresh when we return
    setState(() {});
  }

  Future<void> _onTapListItem(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MasterContainerScreen(
          masterContainerId: _masterContainers[index].id,
          masterContainerIndex: index + 1,
        ),
      ),
    );
    setState(() {});
  }

  Widget _noMasterContainers() {
    return const Center(
      child: Text(
        'No master containers for this trip.',
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _masterContainerList() {
    return ListView.builder(
      itemCount: _masterContainers.length,
      itemBuilder: (BuildContext _, int index) {
        return MasterContainerListItem(
          listIndex: index + 1,
          masterContainer: _masterContainers[index],
          onTap: (id) => _onTapListItem(index),
        );
      },
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _masterContainers.isNotEmpty ? _masterContainerList() : _noMasterContainers(),
        ),
        if (_tripIsActive)
          Container(
            child: StripButton(
              icon: const Icon(Icons.add),
              color: OlracColours.ninetiesGreen,
              onPressed: _onPressCreateStripButton,
              labelText: 'Create Master Container',
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(widget.sourceTripId),
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
        _masterContainers = data['masterContainers'];
        _tripIsActive = data['tripIsActive'] as bool;

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: const Text('Master Containers'),
          ),
          body: _body(),
        );
      },
    );
  }
}
