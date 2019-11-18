import 'package:flutter/material.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

class FishingMethodScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Fishing Method')),
        body: Container(
          padding: EdgeInsets.all(10),
          child: GridView.count(
            crossAxisCount: 2,
            children: fishingMethods.map((FishingMethod method) {
              return Card(
                child: FlatButton(
                    child: Text(method.name),
                    onPressed: () async {
                      bool answer = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              ConfirmDialog('Start haul?', 'Are you sure?'));
                      if (answer) {
                        Navigator.pop(context, method);
                      }
                    }),
              );
            }).toList(),
          ),
        ));
  }
}
