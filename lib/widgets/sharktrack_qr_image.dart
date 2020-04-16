import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharkTrackQrImage extends StatelessWidget {
  SharkTrackQrImage({
    @required this.data,
    this.size = 200,
    this.title,
    this.subtitle,
    this.onPressed,
    this.onLongPress,
    this.renderKey,
  }) : assert(data != null);

  final String data;
  final double size;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final GlobalKey renderKey;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: onPressed,
      onLongPress: onLongPress,
      child: RepaintBoundary(
        key: renderKey,
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              QrImage(
                data: data,
                version: QrVersions.auto,
                size: size,
                embeddedImage: AssetImage('assets/images/shark_track_icon_bw.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(size: Size(36, 36)),
              ),
              if (title != null) Text(title, style: TextStyle(fontSize: 12)),
              if (subtitle != null) Text(subtitle, style: TextStyle(fontSize: 11))
            ],
          ),
        ),
      ),
    );
  }
}
