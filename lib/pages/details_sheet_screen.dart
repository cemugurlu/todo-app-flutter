import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class DetailsSheetScreen extends StatelessWidget {
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxBool isCalendarVisible = RxBool(false);

  String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                isCalendarVisible.toggle();
              },
              child: Obx(() => ListTile(
                    title: Text(
                      selectedDate.value != null ? formatDate(selectedDate.value!) : 'Select Date',
                      style: TextStyle(
                        color: selectedDate.value != null ? Colors.black : Colors.grey,
                      ),
                    ),
                    trailing: Icon(
                      isCalendarVisible.value ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue,
                    ),
                  )),
            ),
            Obx(() => Visibility(
                  visible: isCalendarVisible.value,
                  child: SizedBox(
                    height: 200,
                    child: CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateChanged: (date) {
                        selectedDate.value = date;
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {},
              child: const ListTile(
                title: Text(
                  'Priority',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                // Handle attach file button tap
              },
              child: const ListTile(
                title: Text(
                  'Attach a File',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                trailing: Icon(Icons.attach_file, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
