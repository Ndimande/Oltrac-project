import 'package:flutter/material.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

class FishingMethodScreen extends StatelessWidget {
  _onCardPressed(context, method) async {
    bool answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
          'Start Haul?', 'Are you sure you want to start a ${method.name.toLowerCase()} haul?'),
    );

    if (answer) {
      Navigator.pop(context, method);
    }
  }

  Widget _buildFishingMethodCard(FishingMethod method) {
    final child = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          method.abbreviation,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Divider(),
        ),
        Text(
          method.name,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
    return Builder(builder: (BuildContext context) {
      return Card(
        margin: EdgeInsets.all(5),
        child: FlatButton(
          child: child,
          onPressed: () async => _onCardPressed(context, method),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final fishingMethodsAlphabetical = fishingMethods;
    fishingMethodsAlphabetical.sort((a, b) => a.name.compareTo(b.name));
    return Scaffold(
        appBar: AppBar(title: Text('Select Fishing Method')),
        body: Container(
          padding: EdgeInsets.all(10),
          child: GridView.count(
            crossAxisCount: 2,
            children: fishingMethodsAlphabetical
                .map((FishingMethod method) => _buildFishingMethodCard(method))
                .toList(),
          ),
        ));
  }
}
