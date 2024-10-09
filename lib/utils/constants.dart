import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  static const String appName = 'Freelexity';
  static late String appVersion;
  static const String githubUrl =
      'https://github.com/TheGuyDangerous/Freelexity';
  static const String contactEmail = 'sannidhyadubey@gmail.com';

  static Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = packageInfo.version;
  }

  static const String kFirstLaunchKey = 'first_launch';
}
