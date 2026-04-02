String formatMinutesToHm(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return "${h}h ${m}m";
}