import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static final Logger _logger = Logger(
    printer: SimplePrinter(),
    level: kReleaseMode ? Level.off : Level.trace,
  );

  static void trace(dynamic message) => _logger.t(message);

  static void debug(dynamic message) => _logger.d(message);

  static void info(dynamic message) => _logger.i(message);

  static void warning(dynamic message) => _logger.w(message);

  static void error(dynamic message) => _logger.e(message);

  static void wtf(dynamic message) => _logger.f(message);
}
