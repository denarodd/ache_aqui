String _dois(int n) => n.toString().padLeft(2, '0');

String dataCurta(DateTime d) => '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

String dataHora(DateTime d) =>
    '${dataCurta(d)} às ${_dois(d.hour)}:${_dois(d.minute)}';

/// "há 2 h", "há 3 dias", "agora"...
String tempoRelativo(DateTime d) {
  final diff = DateTime.now().difference(d);
  final futuro = diff.isNegative;
  final min = diff.inMinutes.abs();

  if (min < 1) return 'agora';
  if (min >= 43200) return dataCurta(d); // ~30 dias

  String texto;
  if (min < 60) {
    texto = '$min min';
  } else if (min < 1440) {
    texto = '${min ~/ 60} h';
  } else {
    final dias = min ~/ 1440;
    texto = dias == 1 ? '1 dia' : '$dias dias';
  }
  return futuro ? 'em $texto' : 'há $texto';
}

/// Data/hora local no formato ISO 8601 com fuso, ex.: 2026-11-09T08:15:00-03:00
/// (formato que a API espera no campo `data`).
String isoComFuso(DateTime local) {
  final off = local.timeZoneOffset;
  final sinal = off.isNegative ? '-' : '+';
  final a = off.abs();
  final fuso = '$sinal${_dois(a.inHours)}:${_dois(a.inMinutes.remainder(60))}';
  return '${local.year.toString().padLeft(4, '0')}-${_dois(local.month)}-${_dois(local.day)}'
      'T${_dois(local.hour)}:${_dois(local.minute)}:${_dois(local.second)}$fuso';
}
