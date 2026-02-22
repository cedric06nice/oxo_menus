String buildGreeting(String name, DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good morning, $name!';
  if (hour < 17) return 'Good afternoon, $name!';
  return 'Good evening, $name!';
}

int computeGridColumns(double width) {
  if (width < 400) return 1;
  if (width <= 900) return 2;
  return 3;
}
