import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content; // JSON string for Quill Delta

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  bool isPinned;

  @HiveField(7)
  bool isLocked;

  @HiveField(8)
  String? mood;

  @HiveField(9)
  DateTime? selfDestructAt;

  @HiveField(10)
  String? sketchData;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
    this.isLocked = false,
    this.mood,
    this.selfDestructAt,
    this.sketchData,
  });
}
