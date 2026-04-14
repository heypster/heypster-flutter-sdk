import 'dart:async';

import '../dto/heypster_error.dart';

/// Executes [action] with a single retry on transient failures.
///
/// Retries when the action throws a [HeypsterRequestError] that
/// indicates a transient failure:
/// - HTTP 5xx server errors
/// - Timeout exceptions (wrapped in [HeypsterRequestError.cause])
///
/// Does not retry client errors (4xx), decoding errors, or other
/// non-transient failures.
Future<T> withRetry<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on HeypsterRequestError catch (e) {
    final isServerError = e.statusCode != null && e.statusCode! >= 500;
    final isTimeout = e.cause is TimeoutException;

    if (isServerError || isTimeout) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return action();
    }
    rethrow;
  }
}
