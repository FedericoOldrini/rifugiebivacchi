import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Prefisso convenzionale per indicare asset locali bundled nell'app.
///
/// Usato in modalità screenshot (`main_screenshot.dart`) dove le immagini
/// di rete non sono disponibili durante i test di integrazione.
const String assetPrefix = 'asset:';

/// Verifica se [url] punta a un asset locale (prefisso `asset:`).
bool isAssetUrl(String url) => url.startsWith(assetPrefix);

/// Estrae il path dell'asset dal [url] con prefisso `asset:`.
String assetPath(String url) => url.substring(assetPrefix.length);

/// Widget che mostra un'immagine da rete ([CachedNetworkImage]) oppure
/// da asset locale se l'URL inizia con `asset:`.
///
/// Espone la stessa API di base di [CachedNetworkImage] per poter
/// essere usato come drop-in replacement.
class RifugioImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final int? memCacheWidth;

  const RifugioImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (isAssetUrl(imageUrl)) {
      return Image.asset(
        assetPath(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (errorWidget != null) {
            return errorWidget!(context, imageUrl, error);
          }
          return _defaultError(context);
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  Widget _defaultError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(Icons.broken_image_outlined, color: Colors.grey[400]),
    );
  }
}
