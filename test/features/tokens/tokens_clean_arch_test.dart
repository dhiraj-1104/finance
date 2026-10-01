import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/tokens/data/datasources/tokens_remote_data_source.dart';
import 'package:ezbookkeeping/features/tokens/data/models/token_model.dart';
import 'package:ezbookkeeping/features/tokens/data/repositories/tokens_repository_impl.dart';
import 'package:ezbookkeeping/features/tokens/domain/usecases/get_tokens_use_case.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_bloc.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_event.dart';
import 'package:ezbookkeeping/features/tokens/presentation/bloc/tokens_state.dart';
import 'package:ezbookkeeping/features/tokens/utils/user_agent_parser.dart';
import 'package:ezbookkeeping/features/settings/presentation/device_and_sessions_screen.dart';

void main() {
  group('TokenModel & TokenListResponseModel Tests', () {
    test('parses single token correctly from JSON', () {
      final json = {
        'tokenId': 'abc:123:456',
        'tokenType': 1,
        'userAgent': 'ezBookkeeping-Flutter/1.0',
        'lastSeen': 1790744909,
        'isCurrent': true,
      };

      final model = TokenModel.fromJson(json);

      expect(model.tokenId, 'abc:123:456');
      expect(model.tokenType, 1);
      expect(model.userAgent, 'ezBookkeeping-Flutter/1.0');
      expect(model.lastSeen, 1790744909);
      expect(model.isCurrent, isTrue);

      final entity = model.toEntity();
      expect(entity.tokenId, 'abc:123:456');
      expect(entity.tokenType, 1);
      expect(entity.userAgent, 'ezBookkeeping-Flutter/1.0');
      expect(entity.lastSeen, 1790744909);
      expect(entity.isCurrent, isTrue);
    });

    test('parses list response containing multiple tokens and preserves isCurrent', () {
      final json = {
        'result': [
          {
            'tokenId': '3845555739485536256:1790758797:1440759772378758187',
            'tokenType': 1,
            'userAgent':
                'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36',
            'lastSeen': 1790758797,
            'isCurrent': false
          },
          {
            'tokenId': '3845555739485536256:1790745795:1165348709697369856',
            'tokenType': 1,
            'userAgent':
                'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',
            'lastSeen': 1790745795,
            'isCurrent': true
          },
          {
            'tokenId': '3845555739485536256:1790744909:2233175144718543593',
            'tokenType': 1,
            'userAgent': 'ezBookkeeping-Flutter/1.0',
            'lastSeen': 1790744909,
            'isCurrent': false
          }
        ],
        'success': true
      };

      final responseModel = TokenListResponseModel.fromJson(json);

      expect(responseModel.success, isTrue);
      expect(responseModel.tokens.length, 3);
      expect(responseModel.tokens[0].isCurrent, isFalse);
      expect(responseModel.tokens[1].isCurrent, isTrue);
      expect(responseModel.tokens[2].userAgent, 'ezBookkeeping-Flutter/1.0');
    });

    test('parses empty token list response as empty list without errors', () {
      final json = {
        'result': <dynamic>[],
        'success': true,
      };

      final responseModel = TokenListResponseModel.fromJson(json);
      expect(responseModel.success, isTrue);
      expect(responseModel.tokens, isEmpty);
    });

    test('defensively handles missing and null fields in TokenModel', () {
      final model = TokenModel.fromJson(null);
      expect(model.tokenId, '');
      expect(model.tokenType, 1);
      expect(model.userAgent, '');
      expect(model.lastSeen, 0);
      expect(model.isCurrent, isFalse);
    });
  });

  group('UserAgentParser Tests', () {
    test('parses ezBookkeeping app and mobile/desktop clients cleanly', () {
      expect(
        UserAgentParser.parseClientName('ezBookkeeping-Flutter/1.0'),
        'ezBookkeeping Flutter App',
      );

      expect(
        UserAgentParser.parseClientName(
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36',
        ),
        'Chrome on Android',
      );

      expect(
        UserAgentParser.parseClientName(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',
        ),
        'Safari on iPhone',
      );

      expect(
        UserAgentParser.parseClientName(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36',
        ),
        'Chrome on Windows',
      );
    });

    test('isDesktop correctly detects desktop vs mobile platforms', () {
      expect(
        UserAgentParser.isDesktop(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0',
        ),
        isTrue,
      );
      expect(
        UserAgentParser.isDesktop(
          'Mozilla/5.0 (Linux; Android 10; K) Mobile Safari/537.36',
        ),
        isFalse,
      );
      expect(
        UserAgentParser.isDesktop(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X)',
        ),
        isFalse,
      );
    });
  });

  group('TokensRepository & UseCase Tests', () {
    test('returns Right(List<Token>) on successful API fetch', () async {
      final fakeDataSource = _FakeTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: fakeDataSource);
      final useCase = GetTokensUseCase(repository);

      final result = await useCase();

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should have succeeded'),
        (tokens) {
          expect(tokens.length, 3);
          expect(tokens.first.userAgent, contains('Android'));
        },
      );
    });

    test('caches tokens when forceRefresh is false and refreshes when true', () async {
      final fakeDataSource = _FakeTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: fakeDataSource);

      final res1 = await repository.getTokens(forceRefresh: false);
      expect(res1.isRight(), isTrue);
      expect(fakeDataSource.callCount, 1);

      final res2 = await repository.getTokens(forceRefresh: false);
      expect(res2.isRight(), isTrue);
      expect(fakeDataSource.callCount, 1); // Cached

      final res3 = await repository.getTokens(forceRefresh: true);
      expect(res3.isRight(), isTrue);
      expect(fakeDataSource.callCount, 2); // Refreshed
    });

    test('returns Left(ServerFailure) when data source throws Exception', () async {
      final errorDataSource = _ErrorTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: errorDataSource);
      final useCase = GetTokensUseCase(repository);

      final result = await useCase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('API Server Error'));
        },
        (tokens) => fail('Should have failed'),
      );
    });
  });

  group('TokensBloc Tests', () {
    test('emits [TokensLoading, TokensLoaded] on LoadTokens event', () async {
      final fakeDataSource = _FakeTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: fakeDataSource);
      final useCase = GetTokensUseCase(repository);
      final bloc = TokensBloc(getTokens: useCase);

      final states = <TokensState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadTokens());

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const TokensLoading(),
        isA<TokensLoaded>(),
      ]);

      final loadedState = states[1] as TokensLoaded;
      expect(loadedState.tokens.length, 3);

      await sub.cancel();
      await bloc.close();
    });

    test('emits [TokensLoading, TokensError] on failure', () async {
      final errorDataSource = _ErrorTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: errorDataSource);
      final useCase = GetTokensUseCase(repository);
      final bloc = TokensBloc(getTokens: useCase);

      final states = <TokensState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadTokens());

      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, [
        const TokensLoading(),
        isA<TokensError>(),
      ]);

      final errorState = states[1] as TokensError;
      expect(errorState.message, contains('API Server Error'));

      await sub.cancel();
      await bloc.close();
    });
  });

  group('DeviceAndSessionsScreen Widget Tests', () {
    testWidgets('renders screen and displays parsed sessions without exposing raw token IDs', (tester) async {
      final fakeDataSource = _FakeTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: fakeDataSource);
      final useCase = GetTokensUseCase(repository);
      final bloc = TokensBloc(getTokens: useCase);

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceAndSessionsScreen(
            bloc: bloc,
            getTokensUseCase: useCase,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Device & Sessions'), findsOneWidget);
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Other Device'), findsWidgets);
      expect(find.text('Chrome on Android'), findsOneWidget);
      expect(find.text('Safari on iPhone'), findsOneWidget);
      expect(find.text('ezBookkeeping Flutter App'), findsOneWidget);

      // SECURITY CHECK: Ensure sensitive raw token ID strings are NEVER rendered in widget tree
      expect(find.textContaining('3845555739485536256:1790758797:1440759772378758187'), findsNothing);
      expect(find.textContaining('3845555739485536256:1790745795:1165348709697369856'), findsNothing);
    });

    testWidgets('displays empty state when tokens list is empty', (tester) async {
      final emptyDataSource = _EmptyTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: emptyDataSource);
      final useCase = GetTokensUseCase(repository);
      final bloc = TokensBloc(getTokens: useCase);

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceAndSessionsScreen(
            bloc: bloc,
            getTokensUseCase: useCase,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No active sessions found'), findsOneWidget);
    });

    testWidgets('displays error state with retry button when API fails', (tester) async {
      final errorDataSource = _ErrorTokensRemoteDataSource();
      final repository = TokensRepositoryImpl(remoteDataSource: errorDataSource);
      final useCase = GetTokensUseCase(repository);
      final bloc = TokensBloc(getTokens: useCase);

      await tester.pumpWidget(
        MaterialApp(
          home: DeviceAndSessionsScreen(
            bloc: bloc,
            getTokensUseCase: useCase,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('API Server Error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}

class _FakeTokensRemoteDataSource implements TokensRemoteDataSource {
  int callCount = 0;

  @override
  Future<List<TokenModel>> getTokens() async {
    callCount++;
    return const [
      TokenModel(
        tokenId: '3845555739485536256:1790758797:1440759772378758187',
        tokenType: 1,
        userAgent:
            'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36',
        lastSeen: 1790758797,
        isCurrent: false,
      ),
      TokenModel(
        tokenId: '3845555739485536256:1790745795:1165348709697369856',
        tokenType: 1,
        userAgent:
            'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',
        lastSeen: 1790745795,
        isCurrent: true,
      ),
      TokenModel(
        tokenId: '3845555739485536256:1790744909:2233175144718543593',
        tokenType: 1,
        userAgent: 'ezBookkeeping-Flutter/1.0',
        lastSeen: 1790744909,
        isCurrent: false,
      ),
    ];
  }
}

class _EmptyTokensRemoteDataSource implements TokensRemoteDataSource {
  @override
  Future<List<TokenModel>> getTokens() async {
    return const [];
  }
}

class _ErrorTokensRemoteDataSource implements TokensRemoteDataSource {
  @override
  Future<List<TokenModel>> getTokens() async {
    throw const ServerException('API Server Error', 500);
  }
}
