import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../models/user_stats_model.dart';

class AppProvider extends ChangeNotifier {
  final Box<Task> _tasksBox = Hive.box<Task>('tasksBox');
  final Box<UserStats> _statsBox = Hive.box<UserStats>('statsBox');

  List<Task> tasks = [];
  UserStats userStats = UserStats();
  bool isDarkMode = false;

  void loadData() {
    tasks = _tasksBox.values.toList();
    userStats = _statsBox.get('user') ?? UserStats(xp: 0, level: 1, unlockedImages: []);
    
    _checkFailedTasks(); // التحقق من المهام المتأخرة لخصم النقاط
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

// داخل كلاس AppProvider
void addTask(String title, {DateTime? deadline, String priority = 'Medium'}) {
  Task newTask = Task(
    id: DateTime.now().toString(),
    title: title,
    deadline: deadline,
    priority: priority,
  );
  tasks.add(newTask);
  _tasksBox.put(newTask.id, newTask);
  notifyListeners();
}

// دالة لجلب لون المهمة بناءً على أولويتها
Color getPriorityColor(String priority) {
  switch (priority) {
    case 'High': return Colors.redAccent;
    case 'Medium': return Colors.orangeAccent;
    case 'Low': return Colors.greenAccent;
    default: return Colors.white;
  }
}
  void deleteTask(String id) {
    tasks.removeWhere((task) => task.id == id);
    _tasksBox.delete(id);
    notifyListeners();
  }

  void completeTask(String id) {
    for (int i = 0; i < tasks.length; i++) {
      if (tasks[i].id == id && !tasks[i].isCompleted) {
        tasks[i].isCompleted = true;
        _tasksBox.put(id, tasks[i]);

        userStats.xp += 20; // زيادة 20 نقطة
        userStats.level = (userStats.xp ~/ 100) + 1;
        _statsBox.put('user', userStats);
        notifyListeners();
        break;
      }
    }
  }

  // --- ميزة جديدة: خصم النقاط عند التأخير ---
  void _checkFailedTasks() {
    bool hasChanges = false;
    DateTime now = DateTime.now();

    for (var task in tasks) {
      // إذا كان للمهمة وقت، ولم تكتمل، وتخطى الوقت الحالي وقت المهمة
      if (task.deadline != null && !task.isCompleted && now.isAfter(task.deadline!)) {
        userStats.xp -= 10; // خصم 10 نقاط كعقوبة
        if (userStats.xp < 0) userStats.xp = 0; // لا نريد نقاطاً بالسالب
        
        // يمكننا تمديد الوقت قليلاً أو تعليمها كفاشلة، سنمسح الوقت الآن حتى لا يخصم مجدداً
        task.deadline = null; 
        _tasksBox.put(task.id, task);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      userStats.level = (userStats.xp ~/ 100) + 1;
      _statsBox.put('user', userStats);
    }
  }

  // --- ميزة جديدة: متجر الصور ---
  bool buyImage(String imageUrl, int cost) {
    if (userStats.xp >= cost) {
      userStats.xp -= cost; // خصم ثمن الصورة
      List<String> updatedList = List.from(userStats.unlockedImages)..add(imageUrl);
      userStats.unlockedImages = updatedList;
      userStats.currentAvatar = imageUrl; // جعلها الصورة الحالية
      _statsBox.put('user', userStats);
      notifyListeners();
      return true; // نجاح الشراء
    }
    return false; // نقاط غير كافية
  }

  void setAvatar(String imageUrl) {
    if (userStats.unlockedImages.contains(imageUrl)) {
      userStats.currentAvatar = imageUrl;
      _statsBox.put('user', userStats);
      notifyListeners();
    }
  }

  IconData getIconForTask(String title) {
    if (title.contains('دراسة') || title.contains('قراءة')) return Icons.book;
    if (title.contains('تمرين') || title.contains('رياضة')) return Icons.sports_gymnastics;
    if (title.contains('شراء') || title.contains('سوق')) return Icons.shopping_cart;
    return Icons.check_circle;
  }
}