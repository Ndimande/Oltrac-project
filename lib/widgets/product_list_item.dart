import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/westlake/forward_arrow.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/product.dart';

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
      return const ForwardArrow();
    }

    return Icon(
      isSelected ? Icons.check_box : Icons.check_box_outline_blank,
      size: 30,
      color: OlracColours.fauxPasBlue,
    );
  }

  Widget _leading() {
    return const Icon(Icons.local_offer, size: 48, color: OlracColours.fauxPasBlue);
  }

  Widget _title() {
    return Builder(builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            product.productType.name,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            product.tagCode,
            style: Theme.of(context).textTheme.subtitle1,
          ),

        ],
      );
    });
  }

  Widget _subtitle() {
    return Text(friendlyDateTime(product.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? OlracColours.fauxPasBlue[50] : null,
        border: Border(

            top: BorderSide(color: Colors.grey[300], width: 0.5)),
      ),
      padding: const EdgeInsets.all(0),
      child: ListTile(
        onTap: onPressed,
        isThreeLine: true,
        leading: _leading(),
        title: _title(),
        subtitle: _subtitle(),
        trailing: _trailingIcon,
      ),
    );
  }
}
