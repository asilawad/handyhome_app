import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Drop-in replacement for [CachedNetworkImage]: shows a local asset when
/// [imageUrl] points into `assets/` (demo data), otherwise loads it from the
/// network.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit,
    this.width,
    this.height,
  });

  final String imageUrl;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final assetIndex = imageUrl.indexOf('assets/');
    if (assetIndex != -1) {
      return Image.asset(
        imageUrl.substring(assetIndex),
        fit: fit,
        width: width,
        height: height,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: placeholder,
      errorWidget: errorWidget,
      fit: fit,
      width: width,
      height: height,
    );
  }
}
