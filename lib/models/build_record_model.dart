class BuildRecordModel {
  final String version;
  final String platform;
  final String buildType;
  final DateTime timestamp;
  final String gitBranch;
  final String gitCommit;
  final String status;
  final String? changelog;
  final String? downloadLink;
  final String? localBuildPath;

  BuildRecordModel({
    required this.version,
    required this.platform,
    required this.buildType,
    required this.timestamp,
    required this.gitBranch,
    required this.gitCommit,
    required this.status,
    this.changelog,
    this.downloadLink,
    this.localBuildPath,
  });

  String get formattedTimestamp {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year.toString();
    
    int hour = timestamp.hour;
    final period = hour >= 12 ? 'PM' : 'AM';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = timestamp.minute.toString().padLeft(2, '0');
    final secondStr = timestamp.second.toString().padLeft(2, '0');
    
    return '$day/$month/$year $hourStr:$minuteStr:$secondStr $period';
  }

  static DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}

    try {
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        final dateParts = parts[0].split('/');
        final timeParts = parts[1].split(':');
        final period = parts[2];

        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = int.parse(timeParts[2]);

        if (period == 'PM' && hour != 12) {
          hour += 12;
        } else if (period == 'AM' && hour == 12) {
          hour = 0;
        }

        return DateTime(year, month, day, hour, minute, second);
      }
    } catch (_) {}

    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'platform': platform,
      'buildType': buildType,
      'timestamp': formattedTimestamp,
      'gitBranch': gitBranch,
      'gitCommit': gitCommit,
      'status': status,
      if (changelog != null) 'changelog': changelog,
      if (downloadLink != null) 'downloadLink': downloadLink,
      if (localBuildPath != null) 'localBuildPath': localBuildPath,
    };
  }

  factory BuildRecordModel.fromJson(Map<String, dynamic> json) {
    return BuildRecordModel(
      version: json['version'] ?? '',
      platform: json['platform'] ?? '',
      buildType: json['buildType'] ?? '',
      timestamp: json['timestamp'] != null
          ? _parseDate(json['timestamp'])
          : DateTime.now(),
      gitBranch: json['gitBranch'] ?? '',
      gitCommit: json['gitCommit'] ?? '',
      status: json['status'] ?? '',
      changelog: json['changelog'],
      downloadLink: json['downloadLink'],
      localBuildPath: json['localBuildPath'],
    );
  }
}
