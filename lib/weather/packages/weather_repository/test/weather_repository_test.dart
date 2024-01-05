import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as oma;
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock implements oma.OpenMeteoApiClient {}

class MockLocation extends Mock implements oma.Location {}

class MockWeather extends Mock implements oma.Weather {}

void main() {
  group('WeatherRepository', () {
    late oma.OpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoApiClient();
      weatherRepository = WeatherRepository(
        weatherClient: weatherApiClient,
      );
    });

    group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('getWeather', () {
      const city = 'chicago';
      const latitude = 41.85003;
      const longitude = -87.65005;

      test('calls locationSearch with correct city', () async {
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => weatherApiClient.locationSearch(city)).called(1);
      });

      /// Test an exception will return if occurred.
      test('throws when locationSearch failed', () async {
        final exception = Exception('locationSearch failed');
        when(() => weatherApiClient.locationSearch(any())).thenThrow(exception);
        await expectLater(
          weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('call getWeather with correct latitude/longitude', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        try {
          await weatherRepository.getWeather(city);
        } catch (_) {}
        verify(() => weatherApiClient.getWeather(
              latitude: latitude,
              longitude: longitude,
            )).called(1);
      });

      test('throws when getWeather fails', () async {
        final exception = Exception('getWeather failed');
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
            // [any] can also have description.
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(exception);

        await expectLater(
          weatherRepository.getWeather(city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (clear)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(0);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(() => weatherApiClient.getWeather(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
            )).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const Weather(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.clear,
          ),
        );
      });

      test('returns correct weather on success (cloudy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(1);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const Weather(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.cloudy,
          ),
        );
      });
      test('returns correct weather on success (rainy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(51);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const Weather(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.rainy,
          ),
        );
      });

      test('returns correct weather on success (snowy)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(71);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const Weather(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.snowy,
          ),
        );
      });

      test('returns correct weather on success (unknown)', () async {
        final location = MockLocation();
        final weather = MockWeather();
        when(() => location.name).thenReturn(city);
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weather.temperature).thenReturn(42.42);
        when(() => weather.weatherCode).thenReturn(-1);
        when(() => weatherApiClient.locationSearch(any()))
            .thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(city);
        expect(
          actual,
          const Weather(
            temperature: 42.42,
            location: city,
            condition: WeatherCondition.unknown,
          ),
        );
      });
    });
  });
}
