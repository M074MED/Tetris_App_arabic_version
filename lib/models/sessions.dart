class Sessions {
  int pits;
  int rotations;
  double proportion_of_user_drops;
  int minimum_rotation_difference;
  int minimum_translation_difference;
  int maximum_differences;
  int initial_latency;
  int drop_latency;
  int response_latency;
  int max_well;
  int deep_wells;
  double cumulative_wells;
  int column_transitions;
  int row_transitions;
  int landing_height;
  int matches;
  int delta_max_height;
  int delta_pits;
  double pit_depth;
  double lumped_pits;
  int pit_rows;
  int score;
  int tetrises;
  int level;
  int lines;
  int game;
  double avg_lat;
  int cd_9;
  double mean_height;
  int max_height;
  int min_height;
  double pattern_div;
  int total_movements;
  double weighted_cells;
  int jaggedness;
  int wells;
  String username;
  String? objectId;
  DateTime? created;
  DateTime? updated;

  Sessions({
    required this.pits,
    required this.tetrises,
    required this.level,
    required this.lines,
    required this.score,
    required this.game,
    required this.rotations,
    required this.proportion_of_user_drops,
    required this.minimum_rotation_difference,
    required this.minimum_translation_difference,
    required this.maximum_differences,
    required this.initial_latency,
    required this.drop_latency,
    required this.response_latency,
    required this.max_well,
    required this.deep_wells,
    required this.cumulative_wells,
    required this.column_transitions,
    required this.row_transitions,
    required this.landing_height,
    required this.matches,
    required this.delta_max_height,
    required this.delta_pits,
    required this.pit_depth,
    required this.lumped_pits, 
    required this.pit_rows, 
    required this.max_height,
    required this.min_height,
    required this.avg_lat,
    required this.cd_9,
    required this.mean_height,
    required this.pattern_div,
    required this.total_movements,
    required this.weighted_cells,
    required this.jaggedness,
    required this.wells,
    required this.username,
    this.objectId,
    this.created,
    this.updated,
  });

  Map<String, Object?> toJson() => {
        'pits': pits,
        'tetrises': tetrises,
        'score': score,
        'game': game,
        'rotations': rotations,
        'proportion_of_user_drops': proportion_of_user_drops,
        'minimum_rotation_difference': minimum_rotation_difference,
        'minimum_translation_difference': minimum_translation_difference,
        'maximum_differences': maximum_differences,
        'initial_latency': initial_latency,
        'drop_latency': drop_latency,
        'response_latency': response_latency,
        'max_well': max_well,
        'deep_wells': deep_wells,
        'cumulative_wells': cumulative_wells,
        'column_transitions': column_transitions,
        'row_transitions': row_transitions,
        'landing_height': landing_height,
        'matches': matches,
        'delta_max_height': delta_max_height,
        'delta_pits': delta_pits,
        'pit_depth': pit_depth,
        'lumped_pits': lumped_pits,
        'pit_rows': pit_rows,
        'max_height': max_height,
        'min_height': min_height,
        'level': level,
        'lines': lines,
        'avg_lat': avg_lat,
        'cd_9': cd_9,
        'mean_height': mean_height,
        'pattern_div': pattern_div,
        'total_movements': total_movements,
        'weighted_cells': weighted_cells,
        'jaggedness': jaggedness,
        'wells': wells,
        'username': username,
        'created': created,
        'updated': updated,
        'objectId': objectId,
      };

  static Sessions fromJson(Map<dynamic, dynamic>? json) => Sessions(
        pits: json!['pits'] as int,
        score: json['score'] as int,
        game: json['game'] as int,
        lines: json['lines'] as int,
        level: json['level'] as int,
        tetrises: json['tetrises'] as int,
        rotations: json['rotations'] as int,
        proportion_of_user_drops: json['proportion_of_user_drops'] as double,
        minimum_rotation_difference: json['minimum_rotation_difference'] as int,
        minimum_translation_difference:
            json['minimum_translation_difference'] as int,
        maximum_differences: json['maximum_differences'] as int,
        initial_latency: json['initial_latency'] as int,
        drop_latency: json['drop_latency'] as int,
        response_latency: json['response_latency'] as int,
        max_well: json['max_well'] as int,
        deep_wells: json['deep_wells'] as int,
        cumulative_wells: json['cumulative_wells'] as double,
        column_transitions: json['column_transitions'] as int,
        row_transitions: json['row_transitions'] as int,
        landing_height: json['landing_height'] as int,
        matches: json['matches'] as int,
        delta_max_height: json['tetrises'] as int,
        delta_pits: json['delta_pits'] as int,
        pit_depth: json['pit_depth'] as double,
        lumped_pits: json['lumped_pits'] as double,
        pit_rows: json['pit_rows'] as int,
        max_height: json['max_height'] as int,
        min_height: json['min_height'] as int,
        avg_lat: json['avg_lat'] as double,
        cd_9: json['cd_9'] as int,
        mean_height: json['mean_height'] as double,
        pattern_div: json['pattern_div'] as double,
        total_movements: json['total_movements'] as int,
        weighted_cells: json['weighted_cells'] as double,
        jaggedness: json['jaggedness'] as int,
        wells: json['wells'] as int,
        username: json['username'] as String,
        objectId: json['objectId'] as String,
        created: json['created'] as DateTime,
        updated: json['updated'] as DateTime,
      );
}
