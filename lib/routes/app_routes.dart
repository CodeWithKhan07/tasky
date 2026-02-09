import 'package:get/get.dart';
import 'package:todo/routes/route_names.dart';
import 'package:todo/views/AddTodo/add_todo.dart';
import 'package:todo/views/Home/home_screen.dart';

class AppRoutes {
  static Transition transition = Transition.leftToRight;
  static Duration duration = Duration(milliseconds: 500);
  static final getRoutes = [
    GetPage(
      name: RouteNames.home,
      page: () => HomeScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
    GetPage(
      name: RouteNames.addTodo,
      page: () => AddTodoScreen(),
      transition: transition,
      transitionDuration: duration,
    ),
  ];
}
