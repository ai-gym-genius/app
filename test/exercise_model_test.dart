import 'package:flutter_test/flutter_test.dart';
import 'package:gym_genius/core/data/models/exercise_dto.dart';
import 'package:gym_genius/core/data/models/workout_dto.dart';

void main() {
  group('Exercise Logic Test', () {
    test('', () {
      final jsonTraining = {
        'id': 123,
        'duration': 123,
        'startTime': 123,
        'exercises': [
          {
            'exerciseInfo': {
              'id': 1,
              'name': 'penis',
              'description': 'bla bla',
              'imagePath': '123',
              'muscleGroups': ['biceps', 'Triceps'],
            },
            'sets': [
              {
                'weight': 123,
                'reps': 123,
              },
              {
                'weight': 123,
                'reps': 123,
              },
            ]
          },
          {
            'exerciseInfo': {
              'id': 1,
              'name': 'penis',
              'description': 'bla bla',
              'imagePath': '123',
              'muscleGroups': ['biceps', 'Triceps'],
            },
            'sets': [
              {
                'weight': 123,
                'reps': 123,
              },
              {
                'weight': 123,
                'reps': 123,
              },
            ]
          }
        ]
      };

      final workout = WorkoutDTO.fromMap(jsonTraining);
      print(workout);
    });
    test('Another casting test', () {
      final dynamic json = {
        'exerciseInfo': {
          'id': 1,
          'name': 'penis',
          'description': 'bla bla',
          'imagePath': '123',
          'muscleGroups': ['biceps', 'Triceps'],
        },
        'sets': [
          {
            'weight': 123,
            'reps': 123,
          },
          {
            'weight': 123,
            'reps': 123,
          },
        ]
      };

      final parsed = ExerciseDTO.fromMap(json as Map<String, dynamic>);
      print(parsed);
    });
  });
}
