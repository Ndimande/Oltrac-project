import 'package:flutter/material.dart';
import 'package:oltrace/models/tag.dart';

class CreateProductScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreateProductScreenState();
}

class CreateProductScreenState extends State<CreateProductScreen> {
  Widget _buildSourceTags(Tag tagArg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Source Tags'),
        Column(
          children: <Widget>[
            Text(tagArg.tagCode),
            Container(
              alignment: Alignment.centerRight,
              child: RaisedButton(
                child: Text('Add Tag'),
                onPressed: () {},
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Tag tagArg = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Product'),
      ),
      body: Column(
        children: <Widget>[_buildSourceTags(tagArg)],
      ),
    );
  }
}
