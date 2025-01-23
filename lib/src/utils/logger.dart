import 'package:logger/logger.dart';

/// A singleton logger for the Retell Flutter package.
/// 
/// This logger provides consistent logging functionality throughout the package
/// with the ability to enable/disable logging as needed.
class RetellLogger {
  /// The singleton instance of the logger
  static final RetellLogger instance = RetellLogger._internal();
  
  /// Private constructor for singleton pattern
  RetellLogger._internal();

  /// The underlying logger instance
  Logger? _logger;
  
  /// Whether logging is currently enabled
  bool _enabled = true;

  /// Initializes the logger with the specified configuration.
  /// 
  /// [enabled] determines whether logging should be active.
  /// When disabled, all log calls will be ignored.
  void init({bool enabled = true}) {
    _enabled = enabled;
    if (enabled) {
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.dateAndTime,
        ),
      );
    } else {
      _logger = null;
    }
  }

  /// Logs a debug message.
  /// 
  /// The message will be prefixed with "[Retell]" for easy identification.
  /// Only works if logging is enabled.
  void d(String message) {
    if (_enabled) _logger?.d('[Retell] $message');
  }

  /// Logs an error message with an optional error object.
  /// 
  /// The message will be prefixed with "[Retell]" for easy identification.
  /// Only works if logging is enabled.
  void e(String message, [dynamic error]) {
    if (_enabled) _logger?.e('[Retell] $message', error: error);
  }
} 