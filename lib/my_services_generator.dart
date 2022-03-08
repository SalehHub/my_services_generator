//skipGenerator
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

// void main() {
//   String newFolderName = "../my_services";
//   MyGenerator.generate(
//     newFolderName,
//     [
//       // Settings.flutterAppBadger,
//       // Settings.googleMaps,
//       // Settings.imagePicker,
//       // Settings.photoView,
//       // Settings.sharePlus,
//       // Settings.mapLauncher,
//       // Settings.appLinks,
//       // Settings.flutterSvg,
//       // Settings.firebaseCore,
//       // Settings.firebaseCrashlytics,
//       // Settings.firebaseMessaging,
//       // Settings.appSettings,
//       // Settings.pinCodeFields,
//       // Settings.sqflite,
//       // Settings.hive,
//       // Settings.skipGenerator,
//     ],
//   );
// }

extension FileExtention on FileSystemEntity {
  String get name => path.split("/").last;
}

enum Settings {
  flutterAppBadger,
  googleMaps,
  imagePicker,
  photoView,
  sharePlus,
  mapLauncher,
  appLinks,
  flutterSvg,
  firebaseCore,
  firebaseCrashlytics,
  firebaseMessaging,
  appSettings,
  pinCodeFields,
  sqflite,
  hive,
  skipGenerator,
}

class MyGenerator {
  static List<Settings> _toRemove = [];
  static String _newFolderPath = '../my_services';
  static String _sourceFolder = '../';
  static String _zipFileName = 'my_services.zip';
  static String _zipFileFolder = 'my_services_out';

  static Future<void> generate(newFolderPath, List<Settings> toRemove) async {
    String sourceFolder = "$_zipFileFolder/my_services-main";
    _toRemove = toRemove;
    _newFolderPath = newFolderPath;
    _sourceFolder = sourceFolder;

    await downloadRepository();
    print("Repository downloaded.");

    extractZip();
    print("Zip file extracted.");

    createNewFolderName();
    print('my_services Folder created.');

    generatePubspecFile();
    print('Pubspec.yaml generated.');

    generateFiles();
    print("Files & folders generated.");

    await pubGet();

    try {
      File(_zipFileName).deleteSync();
      File(_zipFileFolder).deleteSync(recursive: true);
    } catch (e) {
      print(e);
    }
    print("Delete zip & temp folder.");
  }

  static Future<void> downloadRepository() async {
    final request = await HttpClient().getUrl(Uri.parse('https://github.com/salehahmedZ/my_services/archive/refs/heads/main.zip'));
    final response = await request.close();
    await response.pipe(File(_zipFileName).openWrite());
  }

  static void extractZip() {
    // Read the Zip file from disk.
    final bytes = File(_zipFileName).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);

    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$_zipFileFolder/' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('$_zipFileFolder/' + filename).create(recursive: true);
      }
    }
  }

  static String createNewFolderName() {
    var newFolder = Directory(_newFolderPath);
    if (newFolder.existsSync()) {
      newFolder.deleteSync(recursive: true);
    }
    newFolder.createSync(recursive: true);
    print(newFolder.absolute.path);
    return newFolder.path;
  }

  static void generatePubspecFile() {
    var pubspec = File(_sourceFolder + "/pubspec.yaml");
    var newPubspec = StringBuffer();
    var lines = pubspec.readAsLinesSync();
    for (String line in lines) {
      if (shouldGenerate(line)) {
        newPubspec.writeln(line);
      }
    }
    var f = File(_newFolderPath + "/pubspec.yaml");
    f.createSync();
    f.writeAsStringSync(newPubspec.toString());
  }

  static String cleanFile(String contents) {
    String t = contents;
    for (var s in _toRemove) {
      String ss = "start-${s.name}";
      String es = "end-${s.name}";
      int start = t.lastIndexOf(ss);
      int end = t.lastIndexOf(es);
      if (start == -1 || end == -1) {
        continue;
      }
      String bad = t.substring(start, end + es.length);
      String result = t.replaceAll(bad, "");
      t = result;
    }

    return t;
  }

  static bool shouldGenerate(String line) {
    for (var s in _toRemove) {
      if ((line.contains("//${s.name}") || line.contains("#${s.name}"))) {
        return false;
      }
    }
    return true;
  }

  static Future<void> pubGet() async {
    await Process.run("flutter", ['clean'], workingDirectory: _newFolderPath);
    print("flutter clean.");

    await Process.run("flutter", ['pub', 'get'], workingDirectory: _newFolderPath);
    print("flutter pub get.");

    await Process.run("flutter", ['pub', 'run', 'build_runner', 'build', '--delete-conflicting-outputs'], workingDirectory: _newFolderPath);
    print("flutter pub run build_runner build --delete-conflicting-outputs.");

    await Process.run("flutter", ['format', '-l', '200', '.'], workingDirectory: _newFolderPath);
    print("flutter format -l 200 . .");
  }

  static void generateFiles() {
    var lib = Directory(_sourceFolder + "/lib");
    copyFiles(lib, _newFolderPath, _sourceFolder);

    List<String> folders = [
      'flags',
      'google_fonts',
    ];

    for (String folder in folders) {
      copyFolder(Directory("$_sourceFolder/$folder"), Directory("$_newFolderPath/$folder"));
      print("Copy $folder folder.");
    }
  }

  static copyFolder(Directory from, Directory to) {
    to.createSync();
    for (FileSystemEntity file in from.listSync()) {
      if (file is File) {
        file.copySync(to.path + "/" + file.name);
      }
    }
  }

  static void copyFiles(Directory folder, String newFolderPath, sourceFolder) {
    String folderPath = folder.path.replaceAll(sourceFolder, "");
    for (FileSystemEntity file in folder.listSync()) {
      try {
        if (file is File) {
          var lines = file.readAsLinesSync();
          if (shouldGenerate(lines.first)) {
            var f = File(newFolderPath + folderPath + "/" + file.name);
            f.createSync(recursive: true);
            var newFile = StringBuffer();

            for (String line in lines) {
              if (shouldGenerate(line)) {
                newFile.writeln(line);
              }
            }
            f.writeAsStringSync(cleanFile(newFile.toString()));
          }
        } else if (file is Directory) {
          copyFiles(file, newFolderPath, sourceFolder);
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
