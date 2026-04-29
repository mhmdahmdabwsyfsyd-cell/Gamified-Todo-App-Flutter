import 'package:hive/hive.dart';

class UserStats {
  int xp;
  int level;
  List<String> unlockedImages; // الصور التي اشتراها
  String? currentAvatar; // الصورة الحالية المستخدمة

  UserStats({
    this.xp = 0, 
    this.level = 1,
    this.unlockedImages = const [], // في البداية لا يملك صور
    this.currentAvatar,
  });
}

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 1;

  @override
  UserStats read(BinaryReader reader) {
    return UserStats(
      xp: reader.readInt(),
      level: reader.readInt(),
      unlockedImages: reader.readList().cast<String>(), // قراءة قائمة الصور
      currentAvatar: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer.writeInt(obj.xp);
    writer.writeInt(obj.level);
    writer.writeList(obj.unlockedImages);
    writer.writeString(obj.currentAvatar ?? ""); // حفظ نص فارغ إذا لم تكن هناك صورة
  }
}