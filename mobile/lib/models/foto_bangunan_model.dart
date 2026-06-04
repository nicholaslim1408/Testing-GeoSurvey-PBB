class FotoBangunanModel {
  final int? id;
  final int taskId;
  final String klasifikasi; // depan, kiri, kanan, belakang
  final String filePath;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  FotoBangunanModel({
    this.id,
    required this.taskId,
    required this.klasifikasi,
    required this.filePath,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  FotoBangunanModel copyWith({
    int? id,
    int? taskId,
    String? klasifikasi,
    String? filePath,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return FotoBangunanModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      klasifikasi: klasifikasi ?? this.klasifikasi,
      filePath: filePath ?? this.filePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'task_id': taskId,
        'klasifikasi': klasifikasi,
        'file_path': filePath,
        'latitude': latitude,
        'longitude': longitude,
        'created_at': createdAt.toIso8601String(),
      };

  static FotoBangunanModel fromJson(Map<String, Object?> json) =>
      FotoBangunanModel(
        id: json['id'] as int?,
        taskId: json['task_id'] as int,
        klasifikasi: json['klasifikasi'] as String,
        filePath: json['file_path'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
