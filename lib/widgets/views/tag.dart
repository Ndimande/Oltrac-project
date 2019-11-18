import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';

class TagView extends StatelessWidget {
  final AppStore _appStore;

  TagView(this._appStore);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: <Widget>[
          Text(
            'What kind of tag?',
            style: TextStyle(fontSize: 32),
          ),
          Column(
            children: <Widget>[
              BigButton(
                label: 'Primary Product',
                onPressed: () {
                  _appStore.changeMainView(NavIndex.tagPrimary);
                },
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                    'The tag will be attached to an individual carcass or bin.'),
              )
            ],
          ),
          Column(
            children: <Widget>[
              BigButton(
                label: 'Secondary Product',
                onPressed: () {
                  _appStore.changeMainView(NavIndex.tagSecondary);
                },
              ),
              Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                      'The tag will be attached to a batch of secondary products, or any individually tagged secondary product units.'))
            ],
          ),
        ],
      ),
    );
  }
}
