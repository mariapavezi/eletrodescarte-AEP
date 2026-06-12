class BrasilTime {
  static const Duration _offset = Duration(hours: -3);

  static DateTime agora() {
    return DateTime.now().toUtc().add(_offset);
  }
}
