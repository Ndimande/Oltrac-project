import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';

class TagSecondaryView extends StatefulWidget {
  final AppStore _appStore;

  TagSecondaryView(this._appStore);

  @override
  _TagSecondaryViewState createState() => _TagSecondaryViewState();
}

class _TagSecondaryViewState extends State<TagSecondaryView> {
  @override
  Widget build(BuildContext context) {
    return Text('Secondary tagging screen coming soon');
  }
}
