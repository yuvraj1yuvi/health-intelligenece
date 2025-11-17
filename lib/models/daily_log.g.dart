// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyLogAdapter extends TypeAdapter<DailyLog> {
  @override
  final int typeId = 0;

  @override
  DailyLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyLog(
      date: fields[0] as DateTime,
      headache: fields[1] as int,
      stress: fields[2] as int,
      fatigue: fields[3] as int,
      painLevel: fields[4] as int,
      mood: fields[5] as int,
      notes: fields[6] as String,
      exerciseMinutes: fields[7] as int,
      sleepHours: fields[8] as int,
      sleepQuality: fields[9] as int,
      waterGlasses: fields[10] as int,
      caffeineIntake: fields[11] as int,
      screenTime: fields[12] as int,
      weather: fields[13] as String,
      activities: (fields[14] as List?)?.cast<String>(),
      triggers: (fields[15] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyLog obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.headache)
      ..writeByte(2)
      ..write(obj.stress)
      ..writeByte(3)
      ..write(obj.fatigue)
      ..writeByte(4)
      ..write(obj.painLevel)
      ..writeByte(5)
      ..write(obj.mood)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.exerciseMinutes)
      ..writeByte(8)
      ..write(obj.sleepHours)
      ..writeByte(9)
      ..write(obj.sleepQuality)
      ..writeByte(10)
      ..write(obj.waterGlasses)
      ..writeByte(11)
      ..write(obj.caffeineIntake)
      ..writeByte(12)
      ..write(obj.screenTime)
      ..writeByte(13)
      ..write(obj.weather)
      ..writeByte(14)
      ..write(obj.activities)
      ..writeByte(15)
      ..write(obj.triggers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
