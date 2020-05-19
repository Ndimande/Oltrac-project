import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/widgets/forward_arrow.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final Function onPressed;
  final bool isSelected;
  final bool isSelectable;
  final bool trailingIcon;

  const ProductListItem({
    this.product,
    this.onPressed,
    this.isSelected = false,
    this.trailingIcon = true,
    this.isSelectable = false,
  });

  Widget get _trailingIcon {
    if (trailingIcon == false) {
      return null;
    }

    if (!isSelectable) {
      return ForwardArrow();
    }

    return Icon(
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      size: 30,
      color: OlracColours.olspsBlue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? OlracColours.olspsBlue[50] : null,
        border: Border(
            bottom: BorderSide(color: Colors.grey[300], width: 0.5),
            top: BorderSide(color: Colors.grey[300], width: 0.5)),
      ),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        onTap: onPressed,
        isThreeLine: true,
        leading: Icon(Icons.local_offer, size: 48, color: OlracColours.olspsBlue),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              product.tagCode,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              product.productType.name,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        subtitle: Text(friendlyDateTime(product.createdAt)),
        trailing: _trailingIcon,
      ),
    );
  }
}
