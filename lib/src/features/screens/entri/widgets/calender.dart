import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:welangflood/src/constants/color.dart';

class CalenderForm extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  const CalenderForm({super.key, this.onDateSelected});

  @override
  State<CalenderForm> createState() => _CalenderFormState();
}

class _CalenderFormState extends State<CalenderForm> {
  final TextEditingController _dateController = TextEditingController();
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime);

    // Notify parent AFTER the build phase is complete — fixes setState during build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected?.call(_selectedDateTime);
    });
  }

  Future<void> _pickDateTime(BuildContext context) async {
    // Step 1: pick date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: tPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null || !mounted) return;

    // Step 2: pick time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: tPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year, pickedDate.month, pickedDate.day,
      pickedTime.hour, pickedTime.minute,
    );

    setState(() {
      _selectedDateTime = combined;
      _dateController.text = DateFormat('yyyy-MM-dd HH:mm').format(combined);
    });
    widget.onDateSelected?.call(combined);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width >= 375 ? 375 : screenSize.width - 30,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggal & Waktu Survei',
            style: TextStyle(color: tPrimaryColor, fontSize: 16, fontFamily: 'Inter'),
          ),
          SizedBox(height: screenSize.height * 0.01),
          GestureDetector(
            onTap: () => _pickDateTime(context),
            child: Container(
              height: screenSize.height * 0.055,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tPrimaryColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dateController.text,
                      style: const TextStyle(
                        color: tPrimaryColor,
                        fontFamily: 'Inter',
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: tPrimaryColor, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}