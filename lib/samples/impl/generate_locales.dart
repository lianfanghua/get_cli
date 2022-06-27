import '../interface/sample_interface.dart';

class GenerateLocalesSample extends Sample {
  final String _translationsKeys;
  final String _keys;
  final String _locales;
  GenerateLocalesSample(this._keys, this._locales, this._translationsKeys,
      {String path = 'lib/generated/locales.g.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

// ignore_for_file: lines_longer_than_80_chars
// ignore: avoid_classes_with_only_static_members
class AppTranslation {

\tstatic Map<String, Map<String, String>> translations = {
$_translationsKeys
\t};

}

class LocaleKeys {
LocaleKeys._();
$_keys
}

class Locales {
\t$_locales
}
''';
}

class GenerateLocaleLangsSample extends Sample {
  final String _locales;
  GenerateLocaleLangsSample( this._locales,
      {String path = 'lib/generated/locales.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''
// ignore_for_file: constant_identifier_names, file_names

$_locales
''';
}

class GenerateLocaleTranslationKeysSample extends Sample {
  final String _translationsKeys;
  GenerateLocaleTranslationKeysSample(this._translationsKeys,
      {String path = 'lib/generated/translation.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TranslationService extends Translations {
\tstatic Locale? get locale => Get.deviceLocale;

\tstatic const fallbackLocale = Locale('en', 'US');

\t@override
\tMap<String, Map<String, String>> get keys => {
$_translationsKeys
\t};
}
''';
}

class GenerateLocaleKeysSample extends Sample {
  final String _keys;
  GenerateLocaleKeysSample(this._keys,
      {String path = 'lib/generated/locale_keys.dart'})
      : super(path, overwrite: true);

  @override
  String get content => '''
// ignore_for_file: constant_identifier_names

class LocaleKeys {
\tLocaleKeys._();
$_keys
}
''';
}
