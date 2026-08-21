const _weekdays = [
  'Poniedziałek',
  'Wtorek',
  'Środa',
  'Czwartek',
  'Piątek',
  'Sobota',
  'Niedziela',
];

const _months = [
  'stycznia',
  'lutego',
  'marca',
  'kwietnia',
  'maja',
  'czerwca',
  'lipca',
  'sierpnia',
  'września',
  'października',
  'listopada',
  'grudnia',
];

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String polishDayLabel(DateTime date) {
  final today = DateTime.now();

  if (isSameDay(date, today)) return 'Dziś';
  if (isSameDay(date, today.add(const Duration(days: 1)))) return 'Jutro';

  final weekday = _weekdays[date.weekday - 1];
  final month = _months[date.month - 1];
  return '$weekday, ${date.day} $month';
}

String polishExpiryLabel(DateTime date) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final expiryDate = DateTime(date.year, date.month, date.day);
  final daysLeft = expiryDate.difference(todayDate).inDays;

  if (daysLeft <= 0) return 'Wygasa dziś';
  if (daysLeft == 1) return 'Wygasa jutro';
  return 'Wygasa za $daysLeft dni';
}