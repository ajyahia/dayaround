import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:jimy/core/theme/prayer_block_theme.dart';

class Task {
  final String id;
  final String title;
  final String? notes;
  final String date; // Stored as "yyyy-MM-dd" date-only to avoid timezone issues
  final PrayerBlockType block;
  final int? durationMinutes;
  final bool isDone;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int schemaVersion;

  static const int currentSchemaVersion = 1;

  const Task({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    required this.block,
    this.durationMinutes,
    this.isDone = false,
    this.sortOrder = 0,
    required this.createdAt,
    this.completedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  /// Helper to convert DateTime to date-only string "yyyy-MM-dd"
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Helper to parse date-only string "yyyy-MM-dd" to DateTime
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);
  }

  Task copyWith({
    String? id,
    String? title,
    String? notes,
    bool clearNotes = false,
    String? date,
    PrayerBlockType? block,
    int? durationMinutes,
    bool clearDuration = false,
    bool? isDone,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    int? schemaVersion,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      date: date ?? this.date,
      block: block ?? this.block,
      durationMinutes:
          clearDuration ? null : (durationMinutes ?? this.durationMinutes),
      isDone: isDone ?? this.isDone,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'date': date,
        'block': block.name,
        'durationMinutes': durationMinutes,
        'isDone': isDone,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'schemaVersion': schemaVersion,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String?,
        date: json['date'] as String,
        block: PrayerBlockType.values.byName(json['block'] as String),
        durationMinutes: json['durationMinutes'] as int?,
        isDone: json['isDone'] as bool? ?? false,
        sortOrder: json['sortOrder'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
        schemaVersion: json['schemaVersion'] as int? ?? currentSchemaVersion,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          notes == other.notes &&
          date == other.date &&
          block == other.block &&
          durationMinutes == other.durationMinutes &&
          isDone == other.isDone &&
          sortOrder == other.sortOrder &&
          createdAt == other.createdAt &&
          completedAt == other.completedAt &&
          schemaVersion == other.schemaVersion;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      notes.hashCode ^
      date.hashCode ^
      block.hashCode ^
      durationMinutes.hashCode ^
      isDone.hashCode ^
      sortOrder.hashCode ^
      createdAt.hashCode ^
      completedAt.hashCode ^
      schemaVersion.hashCode;

  @override
  String toString() =>
      'Task(id: $id, title: $title, date: $date, block: ${block.name}, done: $isDone, duration: $durationMinutes min)';
}

/// Hand-written TypeAdapter for Task with schema version handling
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final blockIndex = fields[4] as int? ?? 0;
    final block = (blockIndex >= 0 && blockIndex < PrayerBlockType.values.length)
        ? PrayerBlockType.values[blockIndex]
        : PrayerBlockType.afterDhuhr;

    final createdAtMs = fields[8] as int? ?? 0;
    final completedAtMs = fields[9] as int?;

    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      notes: fields[2] as String?,
      date: fields[3] as String,
      block: block,
      durationMinutes: fields[5] as int?,
      isDone: fields[6] as bool? ?? false,
      sortOrder: fields[7] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      completedAt: completedAtMs != null
          ? DateTime.fromMillisecondsSinceEpoch(completedAtMs)
          : null,
      schemaVersion: fields[10] as int? ?? Task.currentSchemaVersion,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.block.index)
      ..writeByte(5)
      ..write(obj.durationMinutes)
      ..writeByte(6)
      ..write(obj.isDone)
      ..writeByte(7)
      ..write(obj.sortOrder)
      ..writeByte(8)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(9)
      ..write(obj.completedAt?.millisecondsSinceEpoch)
      ..writeByte(10)
      ..write(obj.schemaVersion);
  }
}
