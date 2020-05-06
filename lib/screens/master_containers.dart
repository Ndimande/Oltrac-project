import 'package:flutter/material.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/repositories/master_container.dart';
import 'package:oltrace/screens/master_container.dart';
import 'package:oltrace/screens/master_container_form.dart';
import 'package:oltrace/widgets/master_container_list_item.dart';
import 'package:oltrace/widgets/strip_button.dart';

final MasterContainerRepository _masterContainerRepo = MasterContainerRepository();

Future<Map<String, dynamic>> _load(int tripId) async {
  final List<MasterContainer> masterContainers = await _masterContainerRepo.all(where: 'trip_id = $tripId');
  return <String, dynamic>{
    'masterContainers': masterContainers.reversed.toList(),
  };
}

class MasterContainersScreen extends StatefulWidget {
  final int sourceTripId;
  MasterContainersScreen(this.sourceTripId);

  @override
  _MasterContainersScreenState createState() => _MasterContainersScreenState();
}

class _MasterContainersScreenState extends State<MasterContainersScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MasterContainer> _masterContainers;

  Future<void> _onPressCreateStripButton() async {

    await Navigator.push(
      _scaffoldKey.currentContext,
      MaterialPageRoute(builder: (_) => MasterContainerFormScreen(sourceTripId: widget.sourceTripId),
    ));

    // Refresh when we return
    setState(() {});
  }

  _onTapListItem(MasterContainer masterContainer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MasterContainerScreen(
          masterContainerId: masterContainer.id,
        ),
      ),
    );
  }

  Widget _noMasterContainers() {
    return Center(
      child: Text('No Master Containers',style: TextStyle(fontSize: 16),),
    );
  }

  Widget _masterContainerList() {
    return ListView.builder(
      itemCount: _masterContainers.length,
      itemBuilder: (BuildContext _, int index) {
        return MasterContainerListItem(
          masterContainer: _masterContainers[index],
          onTap: (id) => _onTapListItem(_masterContainers[index]),
        );
      },
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _masterContainers.length > 0 ? _masterContainerList() : _noMasterContainers(),
        ),
        Container(
          child: StripButton(
            icon: Icon(Icons.add),
            color: Colors.green,
            onPressed: _onPressCreateStripButton,
            labelText: 'New Master Container',
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
          return Scaffold();
        }
        final Map data = snapshot.data;
        _masterContainers = data['masterContainers'];

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Master Containers'),
          ),
          body: _body(),
        );
      },
    );
  }
}
