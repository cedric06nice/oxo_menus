String buildGreeting(String name, DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good morning, $name!';
  if (hour < 17) return 'Good afternoon, $name!';
  return 'Good evening, $name!';
}
