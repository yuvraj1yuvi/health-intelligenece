// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goals.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthGoalAdapter extends TypeAdapter<HealthGoal> {
  @override
  final int typeId = 1;

  @override
  HealthGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthGoal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as String,
      target: (fields[4] as Map).cast<String, dynamic>(),
      current: (fields[5] as Map).cast<String, dynamic>(),
      createdAt: fields[6] as DateTime?,
      targetDate: fields[7] as DateTime?,
      isCompleted: fields[8] as bool,
      completedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HealthGoal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.target)
      ..writeByte(5)
      ..write(obj.current)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.targetDate)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmartReminderAdapter extends TypeAdapter<SmartReminder> {
  @override
  final int typeId = 2;

  @override
  SmartReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmartReminder(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      triggerType: fields[3] as String,
      conditions: (fields[4] as Map).cast<String, dynamic>(),
      scheduledTime: fields[5] as DateTime?,
      isEnabled: fields[6] as bool,
      createdAt: fields[7] as DateTime?,
      lastTriggered: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SmartReminder obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.triggerType)
      ..writeByte(4)
      ..write(obj.conditions)
      ..writeByte(5)
      ..write(obj.scheduledTime)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastTriggered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmartReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
