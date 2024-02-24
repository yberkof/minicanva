import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ImageWidget extends StatelessWidget {
  final dynamic urlOrPath;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const ImageWidget({Key? key, required this.urlOrPath, this.width, this.height, this.fit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(urlOrPath is Uint8List){
      return Image.memory(urlOrPath, fit: fit ?? BoxFit.fitHeight, width: width, height: height);
    }
    else
    if (urlOrPath.contains('assets/')) {
      return Image.asset(urlOrPath, fit: fit ?? BoxFit.fitHeight, width: width, height: height);
    } else {
      return CachedNetworkImage(
        imageUrl: urlOrPath,
        fit: fit ?? BoxFit.fitHeight,
        width: width,
        height: height,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            const CupertinoActivityIndicator(),
      );
    }
  }
}
