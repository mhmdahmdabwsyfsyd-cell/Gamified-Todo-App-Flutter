import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/task_model.dart';
import 'models/user_stats_model.dart';
import 'providers/app_provider.dart';
import 'ui/screens/home_screen.dart';

void main() async {
  // التأكد من تشغيل فلاتر بشكل صحيح
  WidgetsFlutterBinding.ensureInitialized();
  
  // تشغيل قاعدة البيانات
  await Hive.initFlutter();
  
  // تعريف قاعدة البيانات بالنماذج الخاصة بنا
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  
  // فتح الصناديق لتخزين البيانات
  await Hive.openBox<Task>('tasksBox');
  await Hive.openBox<UserStats>('statsBox');

  runApp(
    // تشغيل التطبيق مع ربط الـ Provider
    ChangeNotifierProvider(
      create: (context) {
        var provider = AppProvider();
        provider.loadData(); // جلب البيانات القديمة (إن وجدت)
        return provider;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق المهام السهل',
      home: const HomeScreen(),
    );
  }
}