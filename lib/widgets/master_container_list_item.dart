import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/westlake/forward_arrow.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/widgets/master_container_icon.dart';

class MasterContainerListItem extends StatelessWidget {
  final MasterContainer masterContainer;
  final Function(int) onTap;
  final bool selected;
  final int listIndex;

  const MasterContainerListItem({
    @required this.masterContainer,
    this.onTap,
    this.selected = false,
    @required this.listIndex,
  }): assert(listIndex != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? OlracColours.fauxPasBlue[50] : null,
        border: Border(
            bottom: BorderSide(color: Colors.grey[300], width: 0.5),
            top: BorderSide(color: Colors.grey[300], width: 0.5)),
      ),
      child: ListTile(
        leading: MasterContainerIcon(indexNumber: listIndex),
        title: Text(masterContainer.tagCode),
        subtitle: Text(friendlyDateTime(masterContainer.createdAt)),
        trailing: const ForwardArrow(),
        onTap: onTap != null ? () => onTap(masterContainer.id) : null,
      ),
    );
  }
}
