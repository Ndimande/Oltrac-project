import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';

class TagView extends StatelessWidget {
  final AppStore _appStore;

  TagView(this._appStore);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            'What kind of tag?',
            style: TextStyle(fontSize: 32),
          ),
          Container(
            child: Column(
              children: <Widget>[
                BigButton(
                  child: Text('Primary Product'),
                  onPressed: () {},
                ),
                Text(
                    'The tag will be attached to an individual carcass or bin.')
              ],
            ),
          ),
          Container(
            child: Column(
              children: <Widget>[
                BigButton(
                  child: Text('Secondary Product'),
                  onPressed: () {},
                ),
                Text(
                    'The tag will be attached to a batch of secondary products, or any individually tagged secondary product units.')
              ],
            ),
          )
        ],
      ),
    );
  }
}
