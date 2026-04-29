import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart'; // استدعاء حزمة ضبط الوقت
import '../../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/image_store_slider.dart'; // استدعاء المتجر المتحرك

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController taskController = TextEditingController();
  final ConfettiController confettiController = ConfettiController(duration: const Duration(seconds: 1));
  DateTime? selectedDeadline; // لتخزين الوقت المحدد للمهمة
  String selectedPriority = 'Medium'; // القيمة الافتراضية للأولوية

  // قائمة باقتراحات المهام
  final List<String> suggestions = ['قراءة كتاب', 'ممارسة الرياضة', 'تطبيق سكشن', 'مراجعة المحاضرات', 'شراء مقاضي'];

  // دالة لاختيار الوقت والتاريخ
  Future<void> _pickDeadline() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDeadline = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: appProvider.isDarkMode 
                ? [Colors.black87, const Color(0xFF1A1A2E)]
                : [const Color(0xFF89CFF0), const Color(0xFFB39EB5)], // ألوان زاهية وجميلة
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 1. شريط المستوى والنقاط والمتجر
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GlassCard(
                      isDarkMode: appProvider.isDarkMode,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  // عرض الصورة (الـ Avatar) الخاصة بالمستخدم
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white24,
                                    backgroundImage: (appProvider.userStats.currentAvatar != null && appProvider.userStats.currentAvatar!.isNotEmpty)
                                        ? AssetImage(appProvider.userStats.currentAvatar!) // استخدام الصورة من Assets
                                        : null,
                                    child: (appProvider.userStats.currentAvatar == null || appProvider.userStats.currentAvatar!.isEmpty)
                                        ? const Icon(Icons.person, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('المستوى: ${appProvider.userStats.level}', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                                      Text('النقاط: ${appProvider.userStats.xp} XP', style: const TextStyle(fontSize: 16, color: Colors.yellowAccent)),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(appProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: Colors.white),
                                onPressed: () => appProvider.toggleTheme(),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Align(alignment: Alignment.centerRight, child: Text("متجر الصور (اضغط للشراء):", style: TextStyle(color: Colors.white70, fontSize: 12))),
                          const SizedBox(height: 5),
                          const ImageStoreSlider(), // إضافة الشريط المتحرك هنا
                        ],
                      ),
                    ),
                  ),

                  // 2. قائمة المهام
                  Expanded(
                    child: ListView.builder(
                      itemCount: appProvider.tasks.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final task = appProvider.tasks[index];
                        // تحقق مما إذا كانت المهمة متأخرة
                        bool isOverdue = task.deadline != null && DateTime.now().isAfter(task.deadline!) && !task.isCompleted;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: Key(task.id),
                            onDismissed: (direction) => appProvider.deleteTask(task.id),
                            background: Container(decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.delete, color: Colors.white)),
                            child: GlassCard(
                              isDarkMode: appProvider.isDarkMode,
                              child: ListTile(
                                // عرض لون الأولوية بجانب الأيقونة
                                leading: SizedBox(
                                  width: 40,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: appProvider.getPriorityColor(task.priority), // استدعاء لون الأولوية
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(appProvider.getIconForTask(task.title), color: isOverdue ? Colors.red : Colors.white),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    color: isOverdue ? Colors.redAccent : Colors.white,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: task.deadline != null 
                                  ? Text(
                                      "الوقت: ${DateFormat('hh:mm a - yyyy/MM/dd').format(task.deadline!)}",
                                      style: TextStyle(color: isOverdue ? Colors.red : Colors.white70, fontSize: 12),
                                    ) 
                                  : null,
                                trailing: Checkbox(
                                  value: task.isCompleted,
                                  activeColor: Colors.green,
                                  onChanged: (value) {
                                    if (value == true && !task.isCompleted) {
                                      appProvider.completeTask(task.id);
                                      HapticFeedback.heavyImpact();
                                      confettiController.play();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 3. الاقتراحات وإضافة المهمة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // شريط الاقتراحات السريعة
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: suggestions.map((sug) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ActionChip(
                                label: Text(sug, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                backgroundColor: Colors.black.withOpacity(0.4), 
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(color: Colors.transparent),
                                ),
                                onPressed: () {
                                  taskController.text = sug;
                                },
                              ),
                            )).toList(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GlassCard(
                          isDarkMode: appProvider.isDarkMode,
                          child: Row(
                            children: [
                              // قائمة منسدلة لاختيار الأولوية
                              PopupMenuButton<String>(
                                icon: Icon(Icons.flag, color: selectedPriority == 'High' ? Colors.redAccent : (selectedPriority == 'Low' ? Colors.greenAccent : Colors.orangeAccent)),
                                tooltip: 'تحديد الأولوية',
                                onSelected: (value) {
                                  setState(() {
                                    selectedPriority = value;
                                  });
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'High', child: Text('عالية 🔴')),
                                  const PopupMenuItem(value: 'Medium', child: Text('متوسطة 🟠')),
                                  const PopupMenuItem(value: 'Low', child: Text('منخفضة 🟢')),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.access_time, color: selectedDeadline != null ? Colors.yellow : Colors.white70),
                                onPressed: _pickDeadline,
                                tooltip: 'تحديد وقت انتهاء',
                              ),
                              Expanded(
                                child: TextField(
                                  controller: taskController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'اكتب مهمتك هنا...',
                                    hintStyle: TextStyle(color: Colors.white70),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.blueAccent, size: 28),
                                onPressed: () {
                                  if (taskController.text.isNotEmpty) {
                                    appProvider.addTask(
                                      taskController.text, 
                                      deadline: selectedDeadline,
                                      priority: selectedPriority // تمرير الأولوية هنا
                                    );
                                    taskController.clear();
                                    setState(() {
                                      selectedDeadline = null; // إعادة تصفير الوقت
                                      selectedPriority = 'Medium'; // إعادة الأولوية للافتراضي
                                    });
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}