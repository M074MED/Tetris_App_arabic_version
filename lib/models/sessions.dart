class Sessions {
  int pits;
  double avg_lat;
  int cd_9;
  double mean_height;
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
