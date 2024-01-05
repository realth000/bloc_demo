import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http show Client, Response;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';

/// A fake http client class type we use in test.
class MockHttpClient extends Mock implements http.Client {}

/// A fake http response type class we use in test.
class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

/// Test body.
void main() {
  /// Tests are divided into groups. We share the same actions that need to run every time for every test in a same group.
  group('Location', () {
    /// Group can be embedded in another group.
    group('formJson', () {
      /// Test building the [Location] type values.
      test('returns correct Location object', () {
        /// [expect] is "assert".
        expect(
          Location.fromJson({
            'id': 4887398,
            'name': 'Chicago',
            'latitude': 41.85003,
            'longitude': -87.65005,
          }),

          /// Use [isA<Type>()] to check object type with "having" method to check its field members.
          /// "having" the field "id" (we describe it as "id") with value 4887398.
          isA<Location>()
              .having((w) => w.id, 'id', 4887398)
              .having((w) => w.name, 'name', 'Chicago')
              .having((w) => w.latitude, 'latitude', 41.85003)
              .having((w) => w.longitude, 'longitude', -87.65005),
        );
      });
    });
  });

  group('Weather', () {
    group('fromJson', () {
      test('returns correct Weather object', () {
        expect(
          Weather.fromJson({
            'temperature': 15.3,
            'weathercode': 63,
          }),
          isA<Weather>()
              .having((w) => w.temperature, 'temperature', 15.3)
              .having((w) => w.weatherCode, 'weatherCode', 63),
        );
      });
    });
  });

  group('OpenMeteoApiClient', () {
    /// Here are the same helper objects we share among all the tests use in the same group.
    ///
    /// [httpClient] is the http client we use to make http requests.
    late http.Client httpClient;

    /// [apiClient] is the client we test for our APIs.
    late OpenMeteoApiClient apiClient;

    /// This function body only run ONCE before this group of tests start.
    setUpAll(() {
      /// Because we need to specified http response for [httpClient] for "any urls" later, here we need to
      /// register fallback Uri.
      ///
      /// Allows [any] and [captureAny] to be used on parameters of type [value].
      registerFallbackValue(FakeUri());
    });

    /// This function body is called EVERY TIME before every test in this group starts.
    setUp(() {
      /// Assign the fake client.
      httpClient = MockHttpClient();

      /// Here [httpClient] is wrapped into [apiClient]
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const query = 'mock-query';
      test('makes correct http request', () async {
        /// Here we make a fake http response that use to reply the query http request.
        final response = MockResponse();

        /// [When] set the status code to 200 when we need it.
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');

        /// When the [httpClient] tries to use "GET" method on "ANY" uri, give the same fake response.
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.locationSearch(query);
        } catch (_) {
          // Check the "GET" method with the following target uri is called once and only once.
          //
          // When verifying results, we are checking that the inner [httpClient]'s related method is called certain times.
          verify(() => httpClient.get(Uri.https(
                'geocoding-api.open-meteo.com',
                '/v1/search',
                {'name': query, 'count': '1'},
              ))).called(1);
        }
      });

      test('throws LocationRequestFailure on non-200 response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        expect(
          () async => apiClient.locationSearch(query),

          /// [throwsA] expects the left side value in [expect] is an exception.
          /// [isA] checks the exception type.
          throwsA(isA<LocationRequestFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on error response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(200);
        when(() => resp.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);

        /// CAUTION!
        /// `await expectLater(() => Future<T>)` can not be replaced with
        /// `expect(await () => Future<T>)`.
        await expectLater(
          apiClient.locationSearch(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on empty response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(200);
        when(() => resp.body).thenReturn('{ "result" : [] }');
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        await expectLater(
          apiClient.locationSearch(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('returns Location on valid response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(200);
        when(() => resp.body).thenReturn('''
{
  "results": [
    {
      "id": 4887398,
      "name": "Chicago",
      "latitude": 41.85003,
      "longitude": -87.65005
    }
  ]
}
''');
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        final actual = await apiClient.locationSearch(query);
        expect(
          actual,
          isA<Location>()
              .having((l) => l.name, 'name', 'Chicago')
              .having((l) => l.id, 'id', 4887398)
              .having((l) => l.latitude, 'latitude', 41.85003)
              .having((l) => l.longitude, 'longitude', -87.65005),
        );
      });
    });

    group('getWeather', () {
      const latitude = 41.85003;
      const longitude = -87.6500;

      test('make correct http request', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(200);
        when(() => resp.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        try {
          await apiClient.getWeather(latitude: latitude, longitude: longitude);
        } catch (_) {}
        verify(() => httpClient.get(
              Uri.https('api.open-meteo.com', 'v1/forecast', {
                'latitude': '$latitude',
                'longitude': '$longitude',
                'current_weather': 'true',
              }),
            )).called(1);
      });

      test('throws WeatherRequestFailure on non-200 response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        await expectLater(
          apiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
          throwsA(isA<WeatherRequestFailure>()),
        );
      });

      test('throws WeatherNotFoundFailure on empty response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(200);
        when(() => resp.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        await expectLater(
          apiClient.getWeather(latitude: latitude, longitude: longitude),
          throwsA(isA<WeatherNotFountFailure>()),
        );
      });

      test('returns Weather on valid response', () async {
        final resp = MockResponse();
        when(() => resp.statusCode).thenReturn(200);
        when(() => resp.body).thenReturn('''
{
  "latitude": 43,
  "longitude": -87.875,
  "generationtime_ms": 0.25,
  "utc_offset_seconds": 0,
  "timezone": "GMT",
  "timezone_abbreviation": "GMT",
  "elevation": 189,
  "current_weather": {
    "temperature": 15.3,
    "windspeed": 25.8,
    "winddirection": 310,
    "weathercode": 63,
    "time": "2022-09-12T01:00"
  }
}
''');
        when(() => httpClient.get(any())).thenAnswer((_) async => resp);
        final actual = await apiClient.getWeather(
            latitude: latitude, longitude: longitude);
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.temperature, 'temperature', 15.3)
              .having((w) => w.weatherCode, 'weatherCode', 63),
        );
      });
    });
  });
}
