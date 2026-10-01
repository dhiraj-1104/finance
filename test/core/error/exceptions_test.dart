import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';

void main() {
  group('AppException and Failure tests', () {
    test('ServerException converts to ServerFailure correctly', () {
      const ex = ServerException('Internal server error.', 500);
      expect(ex.message, equals('Internal server error.'));
      expect(ex.statusCode, equals(500));

      final failure = ex.toFailure();
      expect(failure, isA<ServerFailure>());
      expect(failure.message, equals('Internal server error.'));
      expect(failure.statusCode, equals(500));
    });

    test('NetworkException converts to NetworkFailure correctly', () {
      const ex = NetworkException('Network timeout', 408);
      expect(ex.message, equals('Network timeout'));
      expect(ex.statusCode, equals(408));

      final failure = ex.toFailure();
      expect(failure, isA<NetworkFailure>());
      expect(failure.message, equals('Network timeout'));
      expect(failure.statusCode, equals(408));
    });

    test('UnauthorizedException converts to UnauthorizedFailure correctly', () {
      const ex = UnauthorizedException('Unauthorized', 401);
      expect(ex.message, equals('Unauthorized'));
      expect(ex.statusCode, equals(401));

      final failure = ex.toFailure();
      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, equals('Unauthorized'));
      expect(failure.statusCode, equals(401));
    });

    test('ValidationException converts to ValidationFailure correctly', () {
      const ex = ValidationException('Validation error', 400);
      expect(ex.message, equals('Validation error'));
      expect(ex.statusCode, equals(400));

      final failure = ex.toFailure();
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, equals('Validation error'));
      expect(failure.statusCode, equals(400));
    });

    test('CacheException converts to CacheFailure correctly', () {
      const ex = CacheException('Cache write error');
      expect(ex.message, equals('Cache write error'));

      final failure = ex.toFailure();
      expect(failure, isA<CacheFailure>());
      expect(failure.message, equals('Cache write error'));
    });

    test(
      'NoInternetConnectionException converts to NoInternetConnectionFailure correctly',
      () {
        const ex = NoInternetConnectionException();
        expect(
          ex.message,
          equals('No internet connection. Please check your network.'),
        );

        final failure = ex.toFailure();
        expect(failure, isA<NoInternetConnectionFailure>());
        expect(
          failure.message,
          equals('No internet connection. Please check your network.'),
        );
      },
    );

    test(
      'SomethingWentWrongException converts to SomethingWentWrongFailure correctly',
      () {
        const ex = SomethingWentWrongException();
        expect(ex.message, equals('Something went wrong. Please try again.'));

        final failure = ex.toFailure();
        expect(failure, isA<SomethingWentWrongFailure>());
        expect(
          failure.message,
          equals('Something went wrong. Please try again.'),
        );
      },
    );
  });
}
