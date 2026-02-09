import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/data/models/todo_model.dart';
import 'package:todo/view_models/controllers/todo_controller.dart';
import 'package:todo/views/widgets/input_field.dart';

import '../widgets/time_picker.dart';

class AddTodoScreen extends StatefulWidget {
  final TodoModel? todo;
  final bool isEdit;

  const AddTodoScreen({super.key, this.isEdit = false, this.todo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final taskController = TextEditingController();
  final descController = TextEditingController();
  final controller = Get.put(TodoController());
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final key = GlobalKey<FormState>();

  // Date Picker Logic
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.isEdit) {
      taskController.text = widget.todo!.task;
      descController.text = widget.todo!.desc;
      try {
        DateTime parsedDate = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).parse(widget.todo!.timeline);

        setState(() {
          selectedDate = parsedDate;
          selectedTime = TimeOfDay(
            hour: parsedDate.hour,
            minute: parsedDate.minute,
          );
        });
      } catch (e) {
        print("Error parsing timeline: $e");
      }
    }
  }

  // Time Picker Logic
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.blueAccent,
            surface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Text(
                      widget.isEdit ? "NEW TASK" : "Edit Task",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Inputs
                _buildLabel("TITLE"),
                CustomInput(
                  controller: taskController,
                  hint: "What needs to be done?",
                  icon: Icons.edit_note,
                ),

                const SizedBox(height: 25),

                _buildLabel("DESCRIPTION"),
                CustomInput(
                  controller: descController,
                  hint: "Add more details...",
                  icon: Icons.notes,
                  maxLines: 4,
                ),

                const SizedBox(height: 25),

                // Date & Time Pickers
                Row(
                  children: [
                    Expanded(
                      child: timelineWidget(
                        label: "DATE",
                        value: DateFormat('MMM dd, yyyy').format(selectedDate),
                        icon: Icons.calendar_month,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: timelineWidget(
                        label: "TIME",
                        value: selectedTime.format(context),
                        icon: Icons.access_time_filled,
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Action Button
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (key.currentState!.validate()) {
                        if (widget.isEdit) {
                          final updatedTodo = TodoModel(
                            task: taskController.text,
                            timeline: formatTimeline(
                              date: selectedDate,
                              time: selectedTime,
                            ),
                            isDone: widget.todo!.isDone,
                            desc: descController.text,
                            id: widget.todo!.id,
                          );
                          controller.updateTodo(updatedTodo);
                        } else {
                          controller.addTodo(
                            TodoModel(
                              task: taskController.text,
                              timeline: formatTimeline(
                                date: selectedDate,
                                time: selectedTime,
                              ),
                              isDone: false,
                              desc: descController.text,
                            ),
                          );
                        }
                        Get.back();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      widget.isEdit ? "Update Task" : "SAVE TASK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  String formatTimeline({required DateTime date, required TimeOfDay time}) {
    final combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Format: "Feb 14, 2026 - 09:00 AM"
    return DateFormat('MMM dd, yyyy - hh:mm a').format(combinedDateTime);
  }
}
