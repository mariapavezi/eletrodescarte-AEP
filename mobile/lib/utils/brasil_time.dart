/// Horário de Brasília (UTC-3). O Brasil não usa horário de verão desde 2019.
class BrasilTime {
  static const Duration _offset = Duration(hours: -3);

  static DateTime agora() {
    return DateTime.now().toUtc().add(_offset);
  }
}
