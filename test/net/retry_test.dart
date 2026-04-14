import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:heypster_flutter_sdk/heypster_flutter_sdk.dart';
import 'package:heypster_flutter_sdk/src/net/retry.dart';

void main() {
  group('withRetry', () {
    test('returns result on first success', () async {
      final result = await withRetry(() async => 42);
      expect(result, 42);
    });

    test('retries on 5xx server error', () async {
      var attempts = 0;
      final result = await withRetry(() async {
        attempts++;
        if (attempts == 1) {
          throw HeypsterRequestError(statusCode: 500);
        }
        return 'ok';
      });
      expect(result, 'ok');
      expect(attempts, 2);
    });

    test('retries on 502 server error', () async {
      var attempts = 0;
      final result = await withRetry(() async {
        attempts++;
        if (attempts == 1) {
          throw HeypsterRequestError(statusCode: 502);
        }
        return 'ok';
      });
      expect(result, 'ok');
      expect(attempts, 2);
    });

    test('retries on timeout exception', () async {
      var attempts = 0;
      final result = await withRetry(() async {
        attempts++;
        if (attempts == 1) {
          throw HeypsterRequestError(cause: TimeoutException('timed out'));
        }
        return 'ok';
      });
      expect(result, 'ok');
      expect(attempts, 2);
    });

    test('does not retry on 4xx client error', () async {
      var attempts = 0;
      expect(
        () => withRetry(() async {
          attempts++;
          throw HeypsterRequestError(statusCode: 404);
        }),
        throwsA(isA<HeypsterRequestError>()),
      );
      // withRetry is async, so we need to await it
      try {
        await withRetry(() async {
          attempts++;
          throw HeypsterRequestError(statusCode: 404);
        });
      } on HeypsterRequestError {
        // expected
      }
      // First call: 1 attempt. Second call: 1 attempt. Total: 2.
      expect(attempts, 2);
    });

    test('does not retry on decoding error', () async {
      var attempts = 0;
      try {
        await withRetry<String>(() async {
          attempts++;
          throw HeypsterDecodingError('bad json');
        });
      } on HeypsterDecodingError {
        // expected
      }
      expect(attempts, 1);
    });

    test('does not retry on request error without status code', () async {
      var attempts = 0;
      try {
        await withRetry<String>(() async {
          attempts++;
          throw HeypsterRequestError(cause: Exception('network error'));
        });
      } on HeypsterRequestError {
        // expected
      }
      expect(attempts, 1);
    });

    test('throws after second failure on transient error', () async {
      expect(
        () async => withRetry<String>(() async {
          throw HeypsterRequestError(statusCode: 503);
        }),
        throwsA(isA<HeypsterRequestError>()),
      );
    });
  });
}
