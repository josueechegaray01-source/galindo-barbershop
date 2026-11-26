/// Abre URLs externas. Import condicional: en web usa dart:html,
/// en otras plataformas queda como operación sin efecto.
library;

export 'open_external_stub.dart'
    if (dart.library.html) 'open_external_web.dart';
