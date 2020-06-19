import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/numbered_boat.dart';

class TripSection extends StatelessWidget {
  final Trip trip;
  final bool hasActiveHaul;
  final Function onPressEndTrip;
  final Function onPressEditTrip;
  final Function onPressMasterContainerButton;

  const TripSection({
    @required this.trip,
    @required this.hasActiveHaul,
    @required this.onPressEndTrip,
    @required this.onPressEditTrip,
    @required this.onPressMasterContainerButton,
  }) : assert(onPressMasterContainerButton != null);

  Widget get endTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'End Trip',
          color: hasActiveHaul ? Colors.grey : OlracColours.ninetiesRed,
          onPressed: () async => await onPressEndTrip(),
          icon: const Icon(Icons.stop, color: Colors.white),
        );
      });

  Widget get editTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'Master Container',
          onPressed: onPressMasterContainerButton,
          icon: const Icon(Icons.add, color: Colors.white),
        );
      });

  Widget _started() {
    return Builder(builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Started', style: Theme.of(context).textTheme.caption),
          Text(friendlyDateTime(trip.startedAt), style: Theme.of(context).textTheme.headline6)
        ],
      );
    });
  }

  Widget _duration() {
    return Builder(builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Duration', style: Theme.of(context).textTheme.caption),
          ElapsedCounter(style: Theme.of(context).textTheme.headline6, startedDateTime: trip.startedAt),
        ],
      );
    });
  }

  Widget tripInfo() {
    return Builder(builder: (BuildContext context) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _started(),
              _duration(),
            ],
          ),
        ],
      );
    });
  }

  Widget _editTripButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: IconButton(
        onPressed: onPressEditTrip,
        iconSize: 32,
        icon: const Icon(Icons.edit, color: OlracColours.fauxPasBlue),
      ),
    );
  }

  Widget _stripButtons() {
    return Row(
      children: <Widget>[
        Expanded(child: endTripButton, flex: 3),
        Expanded(child: editTripButton, flex: 5),
      ],
    );
  }

  Widget _body() {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              NumberedBoat(number: trip.id),
              const SizedBox(width: 5),
              tripInfo(),
            ],
          ),
          Row(
            children: [
              LocationButton(location: trip.startLocation),
              const SizedBox(width: 5),
              _editTripButton(),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlracColours.fauxPasBlue[50],
      child: Column(
        children: <Widget>[_body(), _stripButtons()],
      ),
    );
  }
}
