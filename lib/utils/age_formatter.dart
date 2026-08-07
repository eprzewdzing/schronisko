String _monthsWord(int n) {
  if (n == 1) return 'miesiąc';
  final lastDigit = n % 10;
  final lastTwoDigits = n % 100;
  if (lastDigit >= 2 && lastDigit <= 4 && !(lastTwoDigits >= 12 && lastTwoDigits <= 14)) {
    return 'miesiące';
  }
  return 'miesięcy';
}

String _yearsWord(int n) {
  if (n == 1) return 'rok';
  final lastDigit = n % 10;
  final lastTwoDigits = n % 100;
  if (lastDigit >= 2 && lastDigit <= 4 && !(lastTwoDigits >= 12 && lastTwoDigits <= 14)) {
    return 'lata';
  }
  return 'lat';
}

String formatAge(int ageInMonths) {
  if (ageInMonths < 12) {
    return '$ageInMonths ${_monthsWord(ageInMonths)}';
  }

  final years = ageInMonths ~/ 12;
  return '$years ${_yearsWord(years)}';
}