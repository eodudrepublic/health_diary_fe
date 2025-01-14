class CameraModel {
  final String imagePath;
  final DateTime timestamp;

  CameraModel({required this.imagePath, required this.timestamp});

  String get formattedTimestamp =>
      "${timestamp.year}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.day.toString().padLeft(2, '0')} "
      "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}";
}
