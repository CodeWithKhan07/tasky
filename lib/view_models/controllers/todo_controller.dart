import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo/Utils/app_utils.dart';
import 'package:todo/data/models/todo_model.dart';
import 'package:todo/data/repository/todo_repository.dart';

import '../../services/notification_service.dart';

class TodoController extends GetxController {
  TodoRepository todoRepository = TodoRepository();
  final allTodos = [].obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAllTodos();
  }

  void getAllTodos() {
    loading.value = true;
    todoRepository
        .getAllTodos()
        .then((v) {
          allTodos.assignAll(v);
          loading.value = false;
        })
        .onError((error, stacktrace) {
          AppUtils.showToast(error.toString());
        });
  }

  void addTodo(TodoModel todo) {
    todoRepository
        .addTodo(todo)
        .then((value) {
          if (value) {
            AppUtils.showToast("Todo Added Successfully");
            // Parse your timeline string back to DateTime
            DateTime reminderTime = DateFormat(
              'MMM dd, yyyy - hh:mm a',
            ).parse(todo.timeline);

            // Only schedule if the time is in the future
            if (reminderTime.isAfter(DateTime.now())) {
              NotificationService.scheduleNotification(
                todo.id ?? 0,
                "Task Reminder",
                todo.task,
                reminderTime,
              );
            }
            getAllTodos();
          } else {
            AppUtils.showToast("Could not Add Todo");
          }
        })
        .onError((error, stacktrace) {
          AppUtils.showToast(error.toString());
        });
  }

  void updateTodo(TodoModel todo) {
    todoRepository.updateTodo(todo).then((value) {
      if (value) {
        DateTime reminderTime = DateFormat(
          'MMM dd, yyyy - hh:mm a',
        ).parse(todo.timeline);

        if (reminderTime.isAfter(DateTime.now()) && !todo.isDone) {
          NotificationService.scheduleNotification(
            todo.id ?? 0,
            "Task Updated",
            todo.task,
            reminderTime,
          );
        } else {
          // If the new time is in the past or task is done, clear the alarm
          NotificationService.cancelNotification(todo.id ?? 0);
        }

        AppUtils.showToast("Todo Updated Successfully");
        getAllTodos();
      }
    });
  }

  void toggleDone(TodoModel todo) {
    final updatedTodo = TodoModel(
      id: todo.id,
      task: todo.task,
      timeline: todo.timeline,
      desc: todo.desc,
      isDone: !todo.isDone,
    );

    // If the task is being marked as DONE, cancel the reminder
    if (updatedTodo.isDone) {
      NotificationService.cancelNotification(todo.id ?? 0);
    } else {
      // If marked as NOT DONE, re-schedule if time is still in the future
      DateTime reminderTime = DateFormat(
        'MMM dd, yyyy - hh:mm a',
      ).parse(todo.timeline);
      if (reminderTime.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          todo.id ?? 0,
          "Task Reminder",
          todo.task,
          reminderTime,
        );
      }
    }
    updateTodo(updatedTodo);
  }

  void deleteTodo(int id) {
    todoRepository
        .delete(id)
        .then((value) {
          if (value) {
            // Cancel notification when deleted
            NotificationService.cancelNotification(id);
            AppUtils.showToast("Todo Deleted Successfully");
            getAllTodos();
          } else {
            AppUtils.showToast("Could not Delete Todo");
          }
        })
        .onError((error, stacktrace) {
          AppUtils.showToast(error.toString());
        });
  }
}
