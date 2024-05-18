import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plantist/controllers/todo_controller.dart';

class DetailsSheetScreen extends StatelessWidget {
  final Rx<DateTime?> selectedDate;
  final RxBool isCalendarVisible;
  final TodoController todoController = Get.find();

  DetailsSheetScreen({
    Key? key,
    required this.selectedDate,
    required this.isCalendarVisible,
  }) : super(key: key);

  String formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Scaffold(
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
                      trailing: CupertinoContextMenu(
                        child: CupertinoSwitch(
                          value: isCalendarVisible.value,
                          onChanged: (value) {
                            isCalendarVisible.toggle();
                          },
                          activeColor: Colors.green,
                        ),
                        actions: [
                          CupertinoContextMenuAction(
                            child: const Text('Close'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    )),
              ),
              Obx(() => Visibility(
                    visible: isCalendarVisible.value,
                    child: SizedBox(
                      height: 300,
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
                onPressed: () {
                  todoController.pickImage();
                },
                child: const ListTile(
                  title: Text(
                    'Attach Image',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  trailing: Icon(Icons.attach_file, color: Colors.black),
                ),
              ),
              Obx(() {
                final selectedImage = todoController.attachedImage.value;
                if (selectedImage != null) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    width: double.infinity,
                    child: Image.file(
                      selectedImage,
                      fit: BoxFit.cover,
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
