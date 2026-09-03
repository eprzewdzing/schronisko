const List<int> visitBookingHours = [9, 10, 11, 12, 13, 14, 15, 16, 17];

bool isVisitBookingDay(DateTime day) {
  return day.weekday >= DateTime.monday && day.weekday <= DateTime.friday;
}

List<DateTime> generateDaySlots(DateTime day) {
  return visitBookingHours
      .map((hour) => DateTime(day.year, day.month, day.day, hour))
      .toList();
}

List<DateTime> availableSlotsForDay(DateTime day, List<DateTime> bookedSlots) {
  if (!isVisitBookingDay(day)) return [];

  final now = DateTime.now();

  return generateDaySlots(day).where((slot) {
    if (slot.isBefore(now)) return false;

    final isBooked = bookedSlots.any((booked) =>
    booked.year == slot.year &&
        booked.month == slot.month &&
        booked.day == slot.day &&
        booked.hour == slot.hour);

    return !isBooked;
  }).toList();
}