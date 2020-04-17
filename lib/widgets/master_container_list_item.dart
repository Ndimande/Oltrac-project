import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/widgets/forward_arrow.dart';

class MasterContainerListItem extends StatelessWidget {
  final MasterContainer masterContainer;
  final Function(int) onTap;
  final bool selected;

  MasterContainerListItem({
    this.masterContainer,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? OlracColours.olspsBlue[50] : null,
        border: Border(
            bottom: BorderSide(color: Colors.grey[300], width: 0.5),
            top: BorderSide(color: Colors.grey[300], width: 0.5)),
      ),
      child: ListTile(
        title: Text(masterContainer.tagCode),
        subtitle: Text(friendlyDateTime(masterContainer.createdAt)),
        trailing: ForwardArrow(),
        onTap: onTap != null ? () => onTap(masterContainer.id) : null,
      ),
    );
  }
}
