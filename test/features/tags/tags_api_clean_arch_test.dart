import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/tags/data/datasources/tags_remote_data_source.dart';
import 'package:ezbookkeeping/features/tags/data/models/add_transaction_tag_request_model.dart';
import 'package:ezbookkeeping/features/tags/data/models/tag_list_response_model.dart';
import 'package:ezbookkeeping/features/tags/data/models/transaction_tag_model.dart';
import 'package:ezbookkeeping/features/tags/data/repositories/tags_repository_impl.dart';
import 'package:ezbookkeeping/features/tags/domain/repositories/tags_repository.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/add_transaction_tag_use_case.dart';
import 'package:ezbookkeeping/features/tags/domain/usecases/get_transaction_tags_use_case.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_bloc.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_event.dart';
import 'package:ezbookkeeping/features/tags/presentation/bloc/tags_state.dart';
import 'package:ezbookkeeping/features/tags/presentation/transaction_tags_screen.dart';

class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter({this.handler});

  Future<ResponseBody> Function(RequestOptions options)? handler;
  RequestOptions? lastRequestOptions;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    requestCount++;
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'result': [
          {
            'id': '3845464351708282880',
            'name': 'hdhwh',
            'groupId': '0',
            'displayOrder': 3,
            'hidden': false,
          },
        ],
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Add Transaction Tag Request & Response Models', () {
    test('AddTransactionTagRequestModel correctly serializes to JSON', () {
      const request = AddTransactionTagRequestModel(
        name: 'hdhwh',
        groupId: '0',
      );

      final json = request.toJson();
      expect(json, {'name': 'hdhwh', 'groupId': '0'});

      final fromJson = AddTransactionTagRequestModel.fromJson(json);
      expect(fromJson.name, 'hdhwh');
      expect(fromJson.groupId, '0');
      expect(fromJson, request);
    });

    test('TransactionTagModel deserializes server response correctly', () {
      final json = {
        'id': '3845464351708282880',
        'name': 'hdhwh',
        'groupId': '0',
        'displayOrder': 3,
        'hidden': false,
      };

      final model = TransactionTagModel.fromJson(json);
      expect(model.id, '3845464351708282880');
      expect(model.name, 'hdhwh');
      expect(model.groupId, '0');
      expect(model.displayOrder, 3);
      expect(model.hidden, false);

      final entity = model.toEntity();
      expect(entity.id, '3845464351708282880');
      expect(entity.name, 'hdhwh');
      expect(entity.title, 'hdhwh');
      expect(entity.groupId, '0');
      expect(entity.displayOrder, 3);
      expect(entity.hidden, false);
      expect(entity.isHidden, false);
    });

    test('TagListResponseModel parses tag list response', () {
      final json = {
        'success': true,
        'result': [
          {
            'id': '3845464351708282880',
            'name': 'hdhwh',
            'groupId': '0',
            'displayOrder': 3,
            'hidden': false,
          },
        ],
      };

      final response = TagListResponseModel.fromJson(json);
      expect(response.success, true);
      expect(response.result.length, 1);
      expect(response.result.first.name, 'hdhwh');
    });
  });

  group('TagsRemoteDataSource', () {
    late Dio dio;
    late MockHttpAdapter adapter;
    late TagsRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      adapter = MockHttpAdapter();
      dio.httpClientAdapter = adapter;
      dataSource = TagsRemoteDataSourceImpl(dio: dio);
    });

    test(
      'addTag sends POST request to /api/v1/transaction/tags/add.json',
      () async {
        adapter.handler = (options) async {
          expect(options.path, ApiEndpoints.addTransactionTag);
          expect(options.method, 'POST');
          final data = options.data as Map<String, dynamic>;
          expect(data['name'], 'hdhwh');
          expect(data['groupId'], '0');

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {
                'id': '3845464351708282880',
                'name': 'hdhwh',
                'groupId': '0',
                'displayOrder': 3,
                'hidden': false,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        const request = AddTransactionTagRequestModel(
          name: 'hdhwh',
          groupId: '0',
        );

        final tag = await dataSource.addTag(request);
        expect(tag.id, '3845464351708282880');
        expect(tag.name, 'hdhwh');
        expect(tag.groupId, '0');
        expect(tag.displayOrder, 3);
        expect(tag.hidden, false);
      },
    );

    test('addTag throws ServerException on failure response', () async {
      adapter.handler = (options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'success': false,
            'errorMessage': 'Tag already exists',
            'errorCode': 40001,
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = AddTransactionTagRequestModel(
        name: 'hdhwh',
        groupId: '0',
      );

      expect(
        () => dataSource.addTag(request),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('TagsRepositoryImpl', () {
    late Dio dio;
    late MockHttpAdapter adapter;
    late TagsRemoteDataSource dataSource;
    late TagsRepository repository;

    setUp(() {
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      adapter = MockHttpAdapter();
      dio.httpClientAdapter = adapter;
      dataSource = TagsRemoteDataSourceImpl(dio: dio);
      repository = TagsRepositoryImpl(remoteDataSource: dataSource);
    });

    test('addTag updates cache and returns Right(TagItem)', () async {
      adapter.handler = (options) async {
        if (options.path == ApiEndpoints.addTransactionTag) {
          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {
                'id': '3845464351708282880',
                'name': 'hdhwh',
                'groupId': '0',
                'displayOrder': 3,
                'hidden': false,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'success': true, 'result': []}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      // Populate cache first
      await repository.getTags();
      expect(repository.isCacheValid, true);

      const request = AddTransactionTagRequestModel(
        name: 'hdhwh',
        groupId: '0',
      );

      final result = await repository.addTag(request);
      expect(result.isRight(), true);
      result.fold((_) => fail('Should succeed'), (tag) {
        expect(tag.id, '3845464351708282880');
        expect(tag.name, 'hdhwh');
      });

      // Verify cached tags contains the newly added tag
      final cached = await repository.getTags();
      expect(cached.any((t) => t.id == '3845464351708282880'), true);
    });
  });

  group('AddTransactionTagUseCase', () {
    test('calls repository.addTag and returns result', () async {
      final fakeRepo = FakeTagsRepository();
      final useCase = AddTransactionTagUseCase(fakeRepo);

      const request = AddTransactionTagRequestModel(
        name: 'hdhwh',
        groupId: '0',
      );

      final result = await useCase(request);
      expect(result.isRight(), true);
      expect(fakeRepo.lastRequest, request);
    });
  });

  group('TagsBloc', () {
    test('emits TagAdding and TagAddSuccess on AddTagRequested', () async {
      final fakeRepo = FakeTagsRepository();
      final addUseCase = AddTransactionTagUseCase(fakeRepo);
      final getUseCase = GetTransactionTagsUseCase(fakeRepo);
      final bloc = TagsBloc(getTags: getUseCase, addTag: addUseCase);

      const request = AddTransactionTagRequestModel(
        name: 'hdhwh',
        groupId: '0',
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TagAdding>(),
          isA<TagAddSuccess>(),
          isA<TagsLoading>(),
          isA<TagsLoaded>(),
        ]),
      );

      bloc.add(const AddTagRequested(request));
    });
  });

  group('TransactionTagsScreen UI', () {
    testWidgets('renders tags screen and triggers add tag flow', (
      tester,
    ) async {
      final fakeRepo = FakeTagsRepository();
      final addUseCase = AddTransactionTagUseCase(fakeRepo);
      final getUseCase = GetTransactionTagsUseCase(fakeRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionTagsScreen(
            addTransactionTagUseCase: addUseCase,
            getTransactionTagsUseCase: getUseCase,
            tagsRepository: fakeRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Transaction Tags'), findsOneWidget);

      // Tap + button to open inline add tag
      final addButton = find.byIcon(Icons.add_rounded);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Enter tag title
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'hdhwh');
      await tester.pumpAndSettle();

      // Tap save check button
      final saveCheckButton = find.byIcon(Icons.check_rounded);
      expect(saveCheckButton, findsOneWidget);
      await tester.tap(saveCheckButton);
      await tester.pumpAndSettle();

      // Verify newly created tag appears in list
      expect(find.text('hdhwh'), findsOneWidget);
      expect(fakeRepo.lastRequest?.name, 'hdhwh');
      expect(fakeRepo.lastRequest?.groupId, '0');
    });

    testWidgets('displays "No transaction tags available" when tag list is empty', (
      tester,
    ) async {
      final fakeRepo = FakeTagsRepository(initialTags: []);
      final addUseCase = AddTransactionTagUseCase(fakeRepo);
      final getUseCase = GetTransactionTagsUseCase(fakeRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionTagsScreen(
            addTransactionTagUseCase: addUseCase,
            getTransactionTagsUseCase: getUseCase,
            tagsRepository: fakeRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transaction tags available'), findsOneWidget);
    });
  });
}

class FakeTagsRepository implements TagsRepository {
  AddTransactionTagRequestModel? lastRequest;
  final List<TagItem> _tags;

  FakeTagsRepository({List<TagItem>? initialTags})
      : _tags = initialTags ??
            [
              const TagItem(id: '1', name: 'travel', groupId: '0'),
              const TagItem(id: '2', name: 'future', groupId: '0'),
            ];

  @override
  bool get isCacheValid => true;

  @override
  void clearCache() {}

  @override
  Future<List<TagItem>> getTags({bool forceRefresh = false}) async {
    return _tags;
  }

  @override
  Future<Either<Failure, TagItem>> addTag(
    AddTransactionTagRequestModel request,
  ) async {
    lastRequest = request;
    final newTag = TagItem(
      id: '3845464351708282880',
      name: request.name,
      groupId: request.groupId,
      displayOrder: 3,
      hidden: false,
    );
    _tags.add(newTag);
    return Right(newTag);
  }

  @override
  Future<Map<String, TagItem>> getTagsMap({bool forceRefresh = false}) async {
    return {for (var t in _tags) t.id: t};
  }
}
