import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

class FishingMethodScreen extends StatelessWidget {
  _onCardPressed(context, method) async {
    bool answer = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('Start haul?',
          'Are you sure you want to start a ${method.name.toLowerCase()} haul?'),
    );

    if (answer) {
      Navigator.pop(context, method);
    }
  }

  Widget _buildFishingMethodCard(FishingMethod method) {
    return Builder(builder: (BuildContext context) {
      return Card(
        child: FlatButton(
          color: AppConfig.primarySwatch,
          child: Text(
            method.name,
            style: TextStyle(fontSize: 22, color: Colors.white),
            textAlign: TextAlign.center,
          ),
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
        backgroundColor: AppConfig.backgroundColor,
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
