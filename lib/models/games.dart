class Games {
  double avg_pits;
  double avg_rotations;
  double avg_proportion_of_user_drops;
  double avg_minimum_rotation_difference;
  double avg_minimum_translation_difference;
  double avg_maximum_differences;
  double avg_initial_latency;
  double avg_drop_latency;
  double avg_response_latency;
  double avg_max_well;
  double avg_deep_wells;
  double avg_cumulative_wells;
  double avg_column_transitions;
  double avg_row_transitions;
  double avg_landing_height;
  double avg_matches;
  double avg_delta_max_height;
  double avg_delta_pits;
  double avg_pit_depth;
  double avg_lumped_pits;
  double avg_pit_rows;
  int final_score;
  int total_tetrises;
  int level_reached;
  int total_lines_cleared;
  int game;
  double avg_lat;
  double avg_cd_9;
  double avg_mean_height;
  double avg_max_height;
  double avg_min_height;
  double avg_pattern_div;
  double avg_total_movements;
  double avg_weighted_cells;
  double avg_jaggedness;
  double avg_wells;
  double avg_indicator_value;
  String assigned_username;
  String? objectId;
  DateTime? created;
  DateTime? updated;

  Games({
    required this.avg_pits,
    required this.total_tetrises,
    required this.level_reached,
    required this.total_lines_cleared,
    required this.final_score,
    required this.game,
    required this.avg_rotations,
    required this.avg_proportion_of_user_drops,
    required this.avg_minimum_rotation_difference,
    required this.avg_minimum_translation_difference,
    required this.avg_maximum_differences,
    required this.avg_initial_latency,
    required this.avg_drop_latency,
    required this.avg_response_latency,
    required this.avg_max_well,
    required this.avg_deep_wells,
    required this.avg_cumulative_wells,
    required this.avg_column_transitions,
    required this.avg_row_transitions,
    required this.avg_landing_height,
    required this.avg_matches,
    required this.avg_delta_max_height,
    required this.avg_delta_pits,
    required this.avg_pit_depth,
    required this.avg_lumped_pits, 
    required this.avg_pit_rows, 
    required this.avg_max_height,
    required this.avg_min_height,
    required this.avg_lat,
    required this.avg_cd_9,
    required this.avg_mean_height,
    required this.avg_pattern_div,
    required this.avg_total_movements,
    required this.avg_weighted_cells,
    required this.avg_jaggedness,
    required this.avg_wells,
    required this.avg_indicator_value,
    required this.assigned_username,
    this.objectId,
    this.created,
    this.updated,
  });

  Map<String, Object?> toJson() => {
        'avg_pits': avg_pits,
        'total_tetrises': total_tetrises,
        'final_score': final_score,
        'game': game,
        'avg_rotations': avg_rotations,
        'avg_proportion_of_user_drops': avg_proportion_of_user_drops,
        'avg_minimum_rotation_difference': avg_minimum_rotation_difference,
        'avg_minimum_translation_difference': avg_minimum_translation_difference,
        'avg_maximum_differences': avg_maximum_differences,
        'avg_initial_latency': avg_initial_latency,
        'avg_drop_latency': avg_drop_latency,
        'avg_response_latency': avg_response_latency,
        'avg_max_well': avg_max_well,
        'avg_deep_wells': avg_deep_wells,
        'avg_cumulative_wells': avg_cumulative_wells,
        'avg_column_transitions': avg_column_transitions,
        'avg_row_transitions': avg_row_transitions,
        'avg_landing_height': avg_landing_height,
        'avg_matches': avg_matches,
        'avg_delta_max_height': avg_delta_max_height,
        'avg_delta_pits': avg_delta_pits,
        'avg_pit_depth': avg_pit_depth,
        'avg_lumped_pits': avg_lumped_pits,
        'avg_pit_rows': avg_pit_rows,
        'avg_max_height': avg_max_height,
        'avg_min_height': avg_min_height,
        'level_reached': level_reached,
        'total_lines_cleared': total_lines_cleared,
        'avg_lat': avg_lat,
        'avg_cd_9': avg_cd_9,
        'avg_mean_height': avg_mean_height,
        'avg_pattern_div': avg_pattern_div,
        'avg_total_movements': avg_total_movements,
        'avg_weighted_cells': avg_weighted_cells,
        'avg_jaggedness': avg_jaggedness,
        'avg_wells': avg_wells,
        'avg_indicator_value': avg_indicator_value,
        'assigned_username': assigned_username,
        'created': created,
        'updated': updated,
        'objectId': objectId,
      };

  static Games fromJson(Map<dynamic, dynamic>? json) => Games(
        avg_pits: json!['avg_pits'] as double,
        final_score: json['final_score'] as int,
        game: json['game'] as int,
        total_lines_cleared: json['total_lines_cleared'] as int,
        level_reached: json['level_reached'] as int,
        total_tetrises: json['total_tetrises'] as int,
        avg_rotations: json['avg_rotations'] as double,
        avg_proportion_of_user_drops: json['avg_proportion_of_user_drops'] as double,
        avg_minimum_rotation_difference: json['avg_minimum_rotation_difference'] as double,
        avg_minimum_translation_difference:
            json['avg_minimum_translation_difference'] as double,
        avg_maximum_differences: json['avg_maximum_differences'] as double,
        avg_initial_latency: json['avg_initial_latency'] as double,
        avg_drop_latency: json['avg_drop_latency'] as double,
        avg_response_latency: json['avg_response_latency'] as double,
        avg_max_well: json['avg_max_well'] as double,
        avg_deep_wells: json['avg_deep_wells'] as double,
        avg_cumulative_wells: json['avg_cumulative_wells'] as double,
        avg_column_transitions: json['avg_column_transitions'] as double,
        avg_row_transitions: json['avg_row_transitions'] as double,
        avg_landing_height: json['avg_landing_height'] as double,
        avg_matches: json['avg_matches'] as double,
        avg_delta_max_height: json['avg_tetrises'] as double,
        avg_delta_pits: json['avg_delta_pits'] as double,
        avg_pit_depth: json['avg_pit_depth'] as double,
        avg_lumped_pits: json['avg_lumped_pits'] as double,
        avg_pit_rows: json['avg_pit_rows'] as double,
        avg_max_height: json['avg_max_height'] as double,
        avg_min_height: json['avg_min_height'] as double,
        avg_lat: json['avg_lat'] as double,
        avg_cd_9: json['avg_cd_9'] as double,
        avg_mean_height: json['avg_mean_height'] as double,
        avg_pattern_div: json['avg_pattern_div'] as double,
        avg_total_movements: json['avg_total_movements'] as double,
        avg_weighted_cells: json['avg_weighted_cells'] as double,
        avg_jaggedness: json['avg_jaggedness'] as double,
        avg_wells: json['avg_wells'] as double,
        avg_indicator_value: json['avg_indicator_value'] as double,
        assigned_username: json['assigned_username'] as String,
        objectId: json['objectId'] as String,
        created: json['created'] as DateTime,
        updated: json['updated'] as DateTime,
      );
}
