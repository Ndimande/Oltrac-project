import 'package:flutter/material.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/landing_list_item_icon.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class SharkInfoCard extends StatelessWidget {
  final Landing landing;
  final int listIndex;
  final bool showIndex;

  const SharkInfoCard({this.landing, this.listIndex, this.showIndex = true});

  Widget _locationRow() {
    return Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location', style: Theme.of(context).textTheme.caption),
                Text(
                  landing.location.toString(),
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
            const SizedBox(width: 5),
            LocationButton(location: landing.location),
          ],
        ),
      );
    });
  }

  Widget _sharkIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      child: SvgIcon(height: 110, assetPath: SvgIcons.path(landing.species.scientificName)),
    );
  }

  Widget _lengthWeightText() {
    String lengthWeight = landing.weightKilograms;
    if (landing.length != null) {
      lengthWeight += ', ' + landing.lengthCentimeters;
    }
    return Builder(builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weight / Length', style: Theme.of(context).textTheme.caption),
          Text(lengthWeight, style: Theme.of(context).textTheme.headline6),
        ],
      );
    });
  }

  Widget _datetimeText() {
    return Builder(builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date and Time', style: Theme.of(context).textTheme.caption),
          Text(friendlyDateTime(landing.createdAt), style: Theme.of(context).textTheme.headline6),
        ],
      );
    });
  }

  Widget _sharkInfo() {
    return Builder(builder: (BuildContext context) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _lengthWeightText(),
            const SizedBox(height: 5),
            _datetimeText(),
            if (landing.isBulk && landing.individuals != null)
              Text('${landing.individuals} individuals', style: Theme.of(context).textTheme.subtitle1)
          ],
        ),
      );
    });
  }

  Widget _indexIcon() {
    // TODO don't think showIndex is ever false anymore
    if(showIndex == false ) {
      return Container(padding: const EdgeInsets.all(5));
    }
    return Container(
      padding: const EdgeInsets.all(5),
      child: LandingListItemIcon(landing: landing, listIndex: listIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _indexIcon(),
                  _sharkInfo(),
                ],
              ),
              _locationRow(),
            ],
          ),
        ),
        _sharkIcon(),
      ],
    );
  }
}
