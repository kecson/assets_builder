import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

///
/// 将驼峰式命名的字符串转换为下划线大写方式。如果转换前的驼峰式命名的字符串为空，则返回空字符串。</br>
/// 例如：HelloWorld->hello_world
/// @param name 转换前的驼峰式命名的字符串
/// @return 转换后下划线小写方式命名的字符串
///
String underscoreName(String input) {
  if (input == null) {
    return null;
  }
  var regExp = RegExp('[A-Z]');
  var result = input.replaceAllMapped(regExp, (m) {
    var find = m.input.substring(m.start, m.end);
    return '${m.start == 0 ? '' : '_'}${find.toLowerCase()}';
  });
  return result;
}

final codeDir = Directory('lib/generated/');

void addClassField(ClassBuilder classBuilder, String fieldName, String value,
    {String docs}) {
  Field existField;

  for (var i = 0; i < classBuilder.fields.length; i++) {
    var f = classBuilder.fields[i];
    if (f?.name == fieldName) {
      existField = f;
      break;
    }
  }

  if (existField != null) {
    var code = DartEmitter().visitField(existField).toString();
    print('=========================\n'
        'waring: skip add $value to field, has exist field:\n$code');
    return;
  }

  classBuilder.fields.add(Field((field) {
    field
      ..name = fieldName
      ..assignment = Code(value)
      ..static = true
      ..modifier = FieldModifier.constant;
    if (docs?.isNotEmpty ?? false) {
      docs =
          (docs.startsWith('//') || docs.startsWith('///')) ? docs : '///$docs';
      field.docs.add(docs);
    }
  }));
}

void generateCode(ClassBuilder classBuilder, File file) {
  classBuilder.docs.insert(0, '//Automatically generated file.  ');
  var emitter = DartEmitter();
  var clazz = classBuilder?.build();
  var code = DartFormatter().format('${clazz?.accept(emitter)}');
  file?.writeAsStringSync(code);
}
