import 'package:my_services_generator/my_services_generator.dart';

void main() {
  MyGenerator.generate(
    //packages app use
    usedPackages: [
      Package.googleMaps,
      Package.imagePicker,
      Package.photoView,
      Package.sharePlus,
      Package.mapLauncher,
      Package.appLinks,
      Package.flutterSvg,
      Package.firebaseCore,
      Package.firebaseCrashlytics,
      Package.firebaseMessaging,
      Package.firebaseAuth,
      Package.hive,
      Package.appSettings,
      Package.pinCodeFields,
      Package.location,
    ],
  );
}
