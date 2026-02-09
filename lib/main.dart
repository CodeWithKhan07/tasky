import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:todo/data/local/local_database.dart';
import 'package:todo/routes/app_routes.dart';
import 'package:todo/routes/route_names.dart';
import 'package:todo/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalDatabase localDatabase = LocalDatabase.instance;
  localDatabase.getDb();
  await NotificationService.init();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      getPages: AppRoutes.getRoutes,
      initialRoute: RouteNames.home,
    );
  }
}
