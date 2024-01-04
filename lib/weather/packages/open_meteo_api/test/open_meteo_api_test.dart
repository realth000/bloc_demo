import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http show Client, Response;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('Location', () {
    group('formJson', () {
      test('returns correct Location object', () {
        expect(
          Location.fromJson({
            'id': 4887398,
            'name': 'Chicago',
            'latitude': 41.85003,
            'longitude': -87.65005,
          }),
          isA<Location>()
              .having((w) => w.id, 'id', 4887398)
              .having((w) => w.name, 'name', 'Chicago')
              .having((w) => w.latitude, 'latitude', 41.85003)
              .having((w) => w.longitude, 'longitude', -87.656505),
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
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
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
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.locationSearch(query);
        } catch (_) {
          verify(() => httpClient.get(Uri.https(
                'geocoding-api.open-meteo.com',
                '/v1/search',
                {'name': query, 'count': '1'},
              ))).called(1);
        }
      });
    });
  });
}
