import 'dart:convert';

import 'package:gym_genius/core/data/models/workout_dto.dart';
import 'package:gym_genius/core/network/dio_service.dart';
import 'package:http/http.dart' as http;

abstract class RemoteWorkoutDatasource {
  Future<void> saveWorkout(WorkoutDTO workout);
  Future<String> getAIDescription(WorkoutDTO workout);
  Future<List<WorkoutDTO>> fetchWorkouts();
}

class APIWorkoutDatasource implements RemoteWorkoutDatasource {
  const APIWorkoutDatasource(this.client);
  final DioService client;

  @override
  Future<String> getAIDescription(WorkoutDTO workout) async {
    try {
      final data = {
        'model': 'qwen/qwen3-coder:free',
        'messages': [
          {
            'role': 'user',
            'content': 'This is my workout: ${workout.toMap()}.'
                'Return a brief review of the workout, what should be improved and what is already good.'
                'Response format (strictly in JSON, without markdown):'
                '{“review”: “your review of the workout”}'
                'Make 3 paragraphs of text: What is good, What is bad, Summary.'
                'Add newLines between paragraphs.',
          }
        ]
      };

      final response = await http.post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          body: jsonEncode(data),
          headers: {
            'Authorization':
                'Bearer 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',
          });

      print(response.body);

      // First level decode
      // final outerJson = json.decode(response.body) as Map<String, dynamic>;

      // // Get inner stringified JSON
      // final String inner = outerJson['choices'][0]['message']['content'];

      // // Second level decode
      // final Map<String, dynamic> reviewJson = json.decode(inner);
      // return reviewJson['review'];
      return 'Unimplemented';
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Future<void> saveWorkout(WorkoutDTO workout) async {
    // First fetch id;
    final data = await client.get('/users/me') as Map;
    final id = data['id'] as int;

    await client.post(
      '/workouts',
      data: json.encode(workout.toFuckingShit(id)),
    );
  }

  @override
  Future<List<WorkoutDTO>> fetchWorkouts() async {
    final dynamic workouts = await client.get('/workouts/my');
    if (workouts == null) {
      return [];
    }

    final parsedShit = (workouts as List<Map<String, dynamic>>)
        .map(WorkoutDTO.fromBackendMap)
        .toList();

    return parsedShit;
  }
}
