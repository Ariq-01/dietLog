import 'package:intl/intl.dart';

class CalendarLogic {
  // Lazy Getter: Hanya dihitung saat dipanggil pertama kali
  late final List<DateTime> weekDates = _generateDates();

  List<DateTime> _generateDates() {
    return List.generate(7, (index) {
      return DateTime.now().add(Duration(days: index));
    });
  }

  // Fungsi untuk mendapatkan nama hari in englis (Sen, Sel, Rab...)
  String getDayName(DateTime date) {
    return DateFormat.E('id_EN').format(date);
  }
}



// To DO : late final => hive (duration(void async(updateed ui) (wait for users and then update ui)))
// Misal user klik ikon ke-3
// void onDateSelected(int index) {
 // var box = Hive.box('settings');
//  box.put('selected_date_index', index); // Simpan index-nya saja
//}
