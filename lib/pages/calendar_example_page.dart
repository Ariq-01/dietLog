import 'package:flutter/material.dart';
import '../widgets/index.dart';

/// Contoh penggunaan calendar di halaman utama
class CalendarExamplePage extends StatefulWidget {
  const CalendarExamplePage({super.key});

  @override
  State<CalendarExamplePage> createState() => _CalendarExamplePageState();
}

class _CalendarExamplePageState extends State<CalendarExamplePage> {
  DateTime _selectedDate = DateTime.now();

  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    // Handle date selection (misal: fetch data diet untuk tanggal tersebut)
    debugPrint('Selected date: ${date.toIso8601String()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Diet Log Calendar'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Today Button dengan calendar dropdown
            TodayButton(
              initialDate: _selectedDate,
              onDateSelected: _handleDateSelected,
            ),
            
            const SizedBox(height: 24),
            
            // Area untuk menampilkan data berdasarkan tanggal
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selected Date:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
