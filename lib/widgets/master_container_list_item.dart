import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/master_container.dart';

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
        color: selected ? olracBlue[50] : null,
        border: Border(
            bottom: BorderSide(color: Colors.grey[300], width: 0.5),
            top: BorderSide(color: Colors.grey[300], width: 0.5)),
      ),
      child: ListTile(
        leading: Text(masterContainer.tagCode),
        onTap: onTap != null ? () => onTap(masterContainer.id) : null,
      ),
    );
  }
}
