import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:gym_genius/core/data/models/exercise_info_dto.dart';
import 'package:gym_genius/core/domain/entities/exercise_info_entity.dart';

/// Service for loading exercises from json file.
class JsonExerciseInfosLoader {
  static const String _jsonLoadingPath = 'assets/exercises.json';

  /// Value is cached after retrieval.
  List<ExerciseInfoEntity>? exEntities;

  /// Loads entities and cache them.
  Future<List<ExerciseInfoEntity>> loadPureEx() async {
    if (exEntities != null) {
      return exEntities!;
    }

    final raw = await loadDTOEx();
    exEntities = raw.map((inf) => inf.toEntity()).toList();

    return exEntities!;
  }

  /// Loads exercises from json file.
  Future<List<ExerciseInfoDTO>> loadDTOEx() async {
    // Load JSON as a String.
    String jsonExercises;
    try {
      jsonExercises = await rootBundle.loadString(_jsonLoadingPath);
    } catch (e) {
      throw Exception('Failed to load JSON asset: $e');
    }

    // Parse it as a list.
    List<Map<String, dynamic>> exInfosRaw;
    try {
      final decoded = json.decode(jsonExercises) as List<dynamic>;
      exInfosRaw = decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to decode JSON: $e');
    }

    // Get class instances and return them.
    try {
      return exInfosRaw.map(ExerciseInfoDTO.fromJsonMap).toList();
    } catch (e) {
      throw Exception('Failed to transfer DTO to Entities: $e');
    }
  }
}
