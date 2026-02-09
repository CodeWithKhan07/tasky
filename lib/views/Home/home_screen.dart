import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/view_models/controllers/todo_controller.dart';
import 'package:todo/views/AddTodo/add_todo.dart';
import 'package:todo/views/widgets/exit_dialog.dart';

import '../../routes/route_names.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TodoController controller = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If the pop already happened, do nothing

        // Show the confirmation dialog
        final shouldPop = showExitDialog(context);
        // If user pressed "Yes", manually pop the screen
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        // Deep Dark Gradient Background
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              // Glossy AppBar
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "MY TASKS",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // Task List
              Obx(() {
                if (controller.allTodos.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "No tasks left",
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final todo = controller.allTodos[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      print(todo.id);
                                      controller.toggleDone(todo);
                                    },
                                    child: Icon(
                                      todo.isDone
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: todo.isDone
                                          ? Colors.greenAccent
                                          : Colors.white24,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      todo.task,
                                      style: TextStyle(
                                        color: todo.isDone
                                            ? Colors.white.withOpacity(.5)
                                            : Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        decoration: todo.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        decorationColor: Colors.white,
                                        decorationThickness: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      todo.desc,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        decoration: todo.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // --- Added Timeline Row ---
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.blueAccent.withOpacity(
                                            0.8,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          todo.timeline,
                                          style: TextStyle(
                                            color: Colors.blueAccent
                                                .withOpacity(0.8),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Right: Action Buttons (Edit & Delete)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Get.to(
                                        AddTodoScreen(isEdit: true, todo: todo),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit_note,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      controller.deleteTodo(todo.id!);
                                    },
                                    icon: Icon(
                                      Icons.delete_sweep,
                                      color: Colors.redAccent.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }, childCount: controller.allTodos.length),
                  ),
                );
              }),
            ],
          ),
        ),

        // Floating Action Button with Glow
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed(RouteNames.addTodo);
          },
          backgroundColor: Colors.blueAccent,
          elevation: 10,
          label: const Text(
            "NEW TASK",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}
