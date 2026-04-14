/// Errors that can occur in the heypster SDK.
sealed class HeypsterError implements Exception {
  /// A human-readable description of the error.
  String get message;

  @override
  String toString() => 'HeypsterError: $message';
}

/// The SDK has not been configured yet.
///
/// Call [HeypsterFlutterSDK.configure] before using the SDK.
class HeypsterNotConfiguredError extends HeypsterError {
  @override
  String get message =>
      'HeypsterFlutterSDK has not been configured. '
      'Call HeypsterFlutterSDK.configure() first.';
}

/// A network request failed.
class HeypsterRequestError extends HeypsterError {
  /// The HTTP status code, if available.
  final int? statusCode;

  /// The underlying error, if any.
  final Object? cause;

  HeypsterRequestError({this.statusCode, this.cause});

  @override
  String get message {
    if (statusCode != null) {
      return 'Request failed with status $statusCode.';
    }
    return 'Request failed: $cause';
  }
}

/// Failed to decode an API response.
class HeypsterDecodingError extends HeypsterError {
  /// A description of what failed to decode.
  final String detail;

  /// The underlying error, if any.
  final Object? cause;

  HeypsterDecodingError(this.detail, {this.cause});

  @override
  String get message => 'Decoding failed: $detail';
}

/// A required URL was missing from the GIF data.
class HeypsterMissingUrlError extends HeypsterError {
  @override
  String get message => 'GIF URL is missing.';
}
