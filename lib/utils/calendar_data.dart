// Calendar static constants

// Static const data untuk bulan
const List<String> monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

// Hari dalam seminggu
const List<String> weekdayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

// Utility class untuk calendar calculations
class CalendarUtils {
  /// Mendapatkan jumlah hari dalam bulan tertentu
  static int daysInMonth(int year, int month) {
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    }
    if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    return 31;
  }

  /// Cek tahun kabisat
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Mendapatkan hari pertama bulan (0 = Sunday, 6 = Saturday)
  static int firstDayOfMonth(int year, int month) {
    return DateTime(year, month, 1).weekday % 7;
  }

  /// Mendapatkan grid 6 baris untuk calendar (untuk konsistensi UI)
  static List<List<int?>> getCalendarGrid(int year, int month) {
    final daysInMonthCount = daysInMonth(year, month);
    final firstDay = firstDayOfMonth(year, month);
    
    final List<List<int?>> grid = [];
    int dayCounter = 1;
    bool isNextMonth = false;
    
    for (int week = 0; week < 6; week++) {
      final List<int?> weekDays = [];
      
      for (int dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        if (week == 0 && dayOfWeek < firstDay) {
          weekDays.add(null); // Empty cell sebelum awal bulan
        } else if (dayCounter > daysInMonthCount) {
          weekDays.add(null); // Empty cell setelah akhir bulan
          isNextMonth = true;
        } else {
          weekDays.add(dayCounter);
          dayCounter++;
        }
      }
      
      grid.add(weekDays);
      
      if (isNextMonth) break;
    }
    
    return grid;
  }
}
