import 'dart:io';

import 'package:yaml_modify/yaml_modify.dart';

class AppVersionUpdater {
  static void update({String? path, bool second = false}) {
    String fileContent = File(path ?? "pubspec.yaml").readAsStringSync();
    var yml = loadYaml(fileContent);
    var map = getModifiableNode(yml);
    var version = map["version"];

    print("Current version:" + version);
    var newVersion = _updateVersion(version, second);
    print("Updated version:" + newVersion);

    map["version"] = newVersion;

    File(path ?? "pubspec.yaml").writeAsStringSync(toYamlString(map));
  }

  static _updateVersion(String version, bool second) {
    var versionParts = version.split("+");
    var lastPart = versionParts.last;
    var lastPartInt = int.parse(lastPart);
    lastPartInt++;

    var firstPart = versionParts.first;
    var firstParts = firstPart.split(".");

    var fristLastPart = firstParts.last;
    if (second) {
      fristLastPart = firstParts[1];
    }

    var fristLastPartInt = int.parse(fristLastPart);
    fristLastPartInt++;

    firstParts[firstParts.length - (second ? 2 : 1)] = fristLastPartInt.toString();
    var firstPartJoined = firstParts.join(".");

    var newVersion = firstPartJoined + "+" + lastPartInt.toString();
    return newVersion;
  }
}
