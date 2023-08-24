import 'dart:io';

import 'package:yaml_modify/yaml_modify.dart';

class AppVersionUpdater {
  static void update([String? path]) {
    String fileContent = File(path ?? "pubspec.yaml").readAsStringSync();
    var yml = loadYaml(fileContent);
    var map = getModifiableNode(yml);
    var version = map["version"];

    print("Current version:" + version);
    var newVersion = _updateVersion(version);
    print("Updated version:" + newVersion);

    map["version"] = newVersion;

    File(path ?? "pubspec.yaml").writeAsStringSync(toYamlString(map));
  }

  static _updateVersion(version) {
    var versionParts = version.split("+");
    var lastPart = versionParts.last;
    var lastPartInt = int.parse(lastPart);
    lastPartInt++;

    var firstPart = versionParts.first;
    var firstParts = firstPart.split(".");
    var fristLastPart = firstParts.last;
    var fristLastPartInt = int.parse(fristLastPart);
    fristLastPartInt++;

    firstParts[firstParts.length - 1] = fristLastPartInt.toString();
    var firstPartJoined = firstParts.join(".");

    var newVersion = firstPartJoined + "+" + lastPartInt.toString();
    return newVersion;
  }
}
