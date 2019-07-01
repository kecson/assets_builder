import 'dart:async';
import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:yaml/yaml.dart';

import '../utils/utils.dart';
import 'command.dart';

class AssetsBuilder extends Command {
  AssetsBuilder();

  @override
  Future build() {
    parseAssets();
  }

  String get description => 'assets资源文件自动生成.dart文件';

  ///assets资源文件自动生成dart文件
  void parseAssets() {
    var pubSpec = new File('pubspec.yaml');

    var readAsStringSync = pubSpec.readAsStringSync();
    var doc = loadYaml(readAsStringSync);
    final flutter = doc['flutter'];
    if (flutter == null) return;
    final assetsNode = flutter['assets'];
    if (assetsNode == null) return;

    final assetsBuilder = ClassBuilder()
      ..name = 'Assets'
      ..docs.add('///assets resources')
      ..constructors.add(Constructor((builder) {
        builder..name = '_';
      }));

    if (assetsNode is YamlList) {
      assetsNode.forEach((asset) {
        if (File(asset).existsSync()) {
          addAssetFile(File(asset), assetsBuilder);
        } else if (Directory(asset).existsSync()) {
          addAssetDir(Directory(asset), assetsBuilder);
        }
      });
    }

    codeDir.createSync();
    var file =
        File('${codeDir.path}${underscoreName(assetsBuilder.name)}.dart');
    generateCode(assetsBuilder, file);
    print('generate assets $file');
  }

  void addAssetFile(File asset, ClassBuilder assetsBuilder) {
    final assetName = createAssetName(asset?.path ?? '');
    if (assetName?.isNotEmpty ?? false) {
      addClassField(assetsBuilder, assetName, '\'${asset.path}\'');
    }
  }

  void addAssetDir(Directory dir, ClassBuilder assetsBuilder) {
    var list = dir.listSync();
    list.forEach((entry) {
      if (File(entry.path).existsSync()) {
        addAssetFile(File(entry.path), assetsBuilder);
      } else if (Directory(entry.path).existsSync()) {
        addAssetDir(Directory(entry.path), assetsBuilder);
      }
    });
  }

  String createAssetName(String assetPath) {
    var fileAsset = new File(assetPath ?? '');
    if (fileAsset.existsSync()) {
      var assetName = fileAsset.path
          .replaceAll('/', '_')
          .replaceAll('\\', '_')
          .replaceAll('.', '_');
      return assetName;
    } else
      return null;
  }
}
