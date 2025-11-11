import 'package:cloud_firestore/cloud_firestore.dart';

class HealthData {
  final DateTime date;
  final String type;
  final dynamic value;
  final String unit;
  final String status;

  HealthData({
    required this.date,
    required this.type,
    required this.value,
    required this.unit,
    required this.status,
  });

  HealthData copyWith({
    DateTime? date,
    String? type,
    dynamic value,
    String? unit,
    String? status,
  }) {
    return HealthData(
      date: date ?? this.date,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Store as Firestore Timestamp for proper range queries & ordering
      'date': Timestamp.fromDate(date),
      'type': type,
      'value': value,
      'unit': unit,
      'status': status,
    };
  }

  factory HealthData.fromMap(Map<String, dynamic> map) {
    final rawDate = map['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else {
      parsedDate = DateTime.now();
    }

    return HealthData(
      date: parsedDate,
      type: (map['type'] ?? '') as String,
      value: map['value'],
      unit: (map['unit'] ?? '') as String,
      status: (map['status'] ?? '') as String,
    );
  }
}

class BloodPressureData {
  final DateTime date;
  final int systolic;
  final int diastolic;
  final String status;

  BloodPressureData({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.status,
  });
}

class HeartRateData {
  final DateTime date;
  final int bpm;
  final String status;

  HeartRateData({
    required this.date,
    required this.bpm,
    required this.status,
  });
}

class GlucoseData {
  final DateTime date;
  final int level;
  final String mealContext;
  final String status;

  GlucoseData({
    required this.date,
    required this.level,
    required this.mealContext,
    required this.status,
  });
}

class WeightData {
  final DateTime date;
  final double weight;
  final double? bmi;
  final String status;

  WeightData({
    required this.date,
    required this.weight,
    this.bmi,
    required this.status,
  });
}

class SleepData {
  final DateTime date;
  final double hoursSlept;
  final int? deepSleepMinutes;
  final int? remSleepMinutes;
  final int? lightSleepMinutes;
  final int? awakeTimes;
  final String quality;

  SleepData({
    required this.date,
    required this.hoursSlept,
    this.deepSleepMinutes,
    this.remSleepMinutes,
    this.lightSleepMinutes,
    this.awakeTimes,
    required this.quality,
  });
}

class ActivityData {
  final DateTime date;
  final int steps;
  final double? distance;
  final int? caloriesBurned;
  final int? activeMinutes;
  final String status;

  ActivityData({
    required this.date,
    required this.steps,
    this.distance,
    this.caloriesBurned,
    this.activeMinutes,
    required this.status,
  });
}

class HealthGoal {
  final String type;
  final dynamic target;
  final dynamic current;
  final String unit;
  final DateTime startDate;
  final DateTime? endDate;

  HealthGoal({
    required this.type,
    required this.target,
    required this.current,
    required this.unit,
    required this.startDate,
    this.endDate,
  });

  double get progressPercentage {
    if (type == 'steps' ||
        type == 'calories' ||
        type == 'distance' ||
        type == 'activeMinutes') {
      return (current as num) / (target as num);
    } else if (type == 'weight') {
      // For weight loss goals, the progress is inverse
      final initialWeight = target['initial'] as double;
      final targetWeight = target['target'] as double;
      final weightDifference = initialWeight - targetWeight;
      final currentDifference = initialWeight - (current as double);
      return currentDifference / weightDifference;
    }
    return 0.0;
  }
}
