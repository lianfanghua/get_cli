import 'package:dart_style/dart_style.dart';

/**
 * Format a dart file
 */
String formatterDartFile(String content) {
  DartFormatter formatter = DartFormatter();
  return formatter.format(content);
}
