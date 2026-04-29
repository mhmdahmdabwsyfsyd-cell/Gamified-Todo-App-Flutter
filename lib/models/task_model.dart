import 'package:hive/hive.dart';

// هذا الكلاس يمثل المهمة الواحدة
class Task {
  String id;
  String title;
  bool isCompleted;
  DateTime? deadline;
  String priority; // 'High', 'Medium', 'Low'

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.deadline,
    this.priority = 'Medium', // القيمة الافتراضية
  });
}
// هذا الكود يخبر قاعدة البيانات (Hive) كيف تحفظ وتقرأ بيانات المهمة
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.readString(),
      title: reader.readString(),
      isCompleted: reader.readBool(),
      // قراءة الوقت (إذا كان موجوداً)
      deadline: reader.readBool() ? DateTime.parse(reader.readString()) : null, 
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeBool(obj.isCompleted);
    // حفظ الوقت (نحفظ true ثم الوقت، أو false إذا لم يوجد وقت)
    if (obj.deadline != null) {
      writer.writeBool(true);
      writer.writeString(obj.deadline!.toIso8601String());
    } else {
      writer.writeBool(false);
    }
  }
}