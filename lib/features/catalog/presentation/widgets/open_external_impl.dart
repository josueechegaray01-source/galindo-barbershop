/// Implementación de apertura de enlaces externos con url_launcher.
library;

import 'package:url_launcher/url_launcher.dart';

/// Abre una URL en el navegador del sistema (o app nativa si aplica).
Future<void> openExternal(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('No se pudo abrir $url');
  }
}