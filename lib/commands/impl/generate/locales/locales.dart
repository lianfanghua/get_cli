import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

import '../../../../common/utils/logger/log_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../exception_handler/exceptions/cli_exception.dart';
import '../../../../samples/impl/generate_locales.dart';
import '../../../interface/command.dart';

class GenerateLocalesCommand extends Command {
  @override
  String get commandName => 'locales';
  @override
  String? get hint => Translation(LocaleKeys.hint_generate_locales).tr;

  @override
  bool validate() {
    return true;
  }

  @override
  Future<void> execute() async {
    final complexMode = args.isNotEmpty && args.length > 1 ? true : false;
    final inputPath = args.isNotEmpty ? args.first : 'assets/locales';
    final langsOutputPath = complexMode ? args[1] : 'lib/generated';
    final keysOutputPath = complexMode ? args[2] : 'lib/generated';
    final translationKeysOutputPath = complexMode ? args[3] : 'lib/generated';

    if (!await Directory(inputPath).exists()) {
      LogService.error(
          LocaleKeys.error_nonexistent_directory.trArgs([inputPath]));
      return;
    }

    final files = await Directory(inputPath)
        .list(recursive: false)
        .where((entry) => entry.path.endsWith('.json'))
        .toList();

    if (files.isEmpty) {
      LogService.info(LocaleKeys.error_empty_directory.trArgs([inputPath]));
      return;
    }

    final maps = <String, Map<String, dynamic>?>{};
    for (var file in files) {
      try {
        final map = jsonDecode(await File(file.path).readAsString());
        final localeKey = basenameWithoutExtension(file.path);
        maps[localeKey] = map as Map<String, dynamic>?;
      } on Exception catch (_) {
        LogService.error(LocaleKeys.error_invalid_json.trArgs([file.path]));
        rethrow;
      }
    }

    final locales = <String, Map<String, String>>{};
    maps.forEach((key, value) {
      final result = <String, String>{};
      _resolve(value!, result);
      locales[key] = result;
    });

    final keys = <String>{};
    locales.forEach((key, value) {
      value.forEach((key, value) {
        keys.add(key);
      });
    });

    final parsedKeys = complexMode
        ? keys
            .map((e) => '\tstatic const ${e.toUpperCase()} = \'$e\';')
            .join('\n')
        : keys.map((e) => '\tstatic const $e = \'$e\';').join('\n');

    final parsedLocales = StringBuffer();
    final translationsKeys = StringBuffer();
    locales.forEach((key, value) {
      if (complexMode) {
        parsedLocales.writeln('const Map<String, String> $key = {');
        translationsKeys.writeln('\t\t\'$key\' :$key,');
      } else {
        parsedLocales.writeln('\tstatic const $key = {');
        translationsKeys.writeln('\t\t\'$key\' : Locales.$key,');
      }
      value.forEach((key, value) {
        value = _replaceValue(value);
        if (RegExp(r'^[0-9]|[!@#<>?":`~;[\]\\|=+)(*&^%-\s]').hasMatch(key)) {
          throw CliException(
              LocaleKeys.error_special_characters_in_key.trArgs([key]));
        }
        if (complexMode) {
          parsedLocales.writeln('\t\'$key\': \'$value\',');
        } else {
          parsedLocales.writeln('\t\t\'$key\': \'$value\',');
        }
      });
      if (complexMode) {
        parsedLocales.writeln('};');
      } else {
        parsedLocales.writeln('\t};');
      }
      if (complexMode) {
        GenerateLocaleLangsSample(parsedLocales.toString(),
                path:
                    '$langsOutputPath${langsOutputPath.endsWith('/') ? '' : '/'}$key.dart')
            .create(skipFormatter: true);
        parsedLocales.clear();
      }
    });

    if (complexMode) {
      GenerateLocaleKeysSample(parsedKeys, path: keysOutputPath)
          .create(skipFormatter: true);
      GenerateLocaleTranslationKeysSample(translationsKeys.toString(),
              path: translationKeysOutputPath)
          .create(skipFormatter: true);
    } else {
      var newFileModel =
          Structure.model('locales', 'generate_locales', false, on: onCommand);

      GenerateLocalesSample(
              parsedKeys, parsedLocales.toString(), translationsKeys.toString(),
              path: '${newFileModel.path}.g.dart')
          .create();
    }
    LogService.success(LocaleKeys.sucess_locale_generate.tr);
  }

  void _resolve(Map<String, dynamic> localization, Map<String, String?> result,
      [String? accKey]) {
    final sortedKeys = localization.keys.toList();

    for (var key in sortedKeys) {
      if (localization[key] is Map) {
        var nextAccKey = key;
        if (accKey != null) {
          nextAccKey = '${accKey}_$key';
        }
        _resolve(localization[key] as Map<String, dynamic>, result, nextAccKey);
      } else {
        result[accKey != null ? '${accKey}_$key' : key] =
            localization[key] as String?;
      }
    }
  }

  @override
  String? get codeSample =>
      LogService.code('get generate locales assets/locales \n'
          'get generate locales assets/locales on locales');

  @override
  int get maxParameters => 4;
}

String _replaceValue(String value) {
  return value
      .replaceAll("'", "\\'")
      .replaceAll('\n', '\\n')
      .replaceAll('\$', '\\\$');
}
