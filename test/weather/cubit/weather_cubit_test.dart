import 'package:bloc_demo/weather/lib/weather/weather.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart' as wr;

import '../../utils/storage.dart';

const weatherLocation = 'London';
const weatherCondition = wr.WeatherCondition.rainy;
const weatherTemperature = 9.8;

class MockWeatherRepository extends Mock implements wr.WeatherRepository {}

class MockWeather extends Mock implements wr.Weather {}

void main() {
  initHydratedStorage();

  group('WeatherCubit', () {
    late wr.Weather weather;
    late wr.WeatherRepository weatherRepository;
    late WeatherCubit weatherCubit;

    setUp(() async {
      weather = MockWeather();
      weatherRepository = MockWeatherRepository();
      when(() => weather.condition).thenReturn(weatherCondition);
      when(() => weather.location).thenReturn(weatherLocation);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(() => weatherRepository.getWeather(any()))
          .thenAnswer((_) async => weather);
      weatherCubit = WeatherCubit(weatherRepository);
    });

    test('initial state is correct', () {
      final weatherCubit = WeatherCubit(weatherRepository);
      expect(weatherCubit.state, WeatherState());
    });

    test('Json conversion', () {
      final weatherCubit = WeatherCubit(weatherRepository);
      expect(
        weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
        weatherCubit.state,
      );
    });

    group('fetchWeather', () {
      final exception = Exception('test throw');
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is null',
        // Init cubit.
        build: () => weatherCubit,
        // What to do.
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'calls getWeather with correct city',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        verify: (_) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, failure] when getWeather throws',
        setUp: () {
          when(() => weatherRepository.getWeather(any())).thenThrow(exception);
        },
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        // Check state results.
        expect: () => <WeatherState>[
          WeatherState(status: const WeatherStatusLoading()),
          WeatherState(status: WeatherStatusFailure(exception.toString())),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emit [loading, success] when getWeather returns (celsius)',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => [
          WeatherState(status: const WeatherStatusLoading()),
          isA<WeatherState>()
              .having((w) => w.status, 'status', const WeatherStatusSuccess())
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having((w) => w.temperature, 'temperature',
                        const Temperature(value: weatherTemperature))
                    .having((w) => w.location, 'location', weatherLocation),
              )
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emit [loading, success] when getWeather returns (fahrenheit)',
        build: () => weatherCubit,

        /// [seed] is an optional `Function` that returns a state
        /// which will be used to seed the `bloc` before [act] is called.
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),

        /// [act] is an optional callback which will be invoked with the `bloc` under
        /// test and should be used to interact with the `bloc`.
        act: (cubit) => cubit.fetchWeather(weatherLocation),
        expect: () => [
          WeatherState(
            status: const WeatherStatusLoading(),
            temperatureUnits: TemperatureUnits.fahrenheit,
          ),
          isA<WeatherState>()
              .having((w) => w.status, 'status', const WeatherStatusSuccess())
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having((w) => w.temperature, 'temperature',
                        Temperature(value: weatherTemperature.toFahrenheit()))
                    .having((w) => w.location, 'location', weatherLocation),
              )
        ],
      );
    });

    group('refreshWeather', () {
      final exception = Exception('test throw');
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when status is not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.refreshWeather(),
        verify: (_) {
          // Verify never called.
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when location is null',
        build: () => weatherCubit,
        seed: () => WeatherState(status: const WeatherStatusSuccess()),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) {
          verifyNever(() => weatherRepository.getWeather(any()));
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'invokes getWeather with correct location',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: const WeatherStatusSuccess(),
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
            lastUpdated: DateTime(DateTime.now().year),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        verify: (_) {
          verify(() => weatherRepository.getWeather(weatherLocation)).called(1);
        },
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when exception is thrown',
        setUp: () {
          when(() => weatherRepository.getWeather(any())).thenThrow(exception);
        },
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: const WeatherStatusSuccess(),
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: weatherTemperature),
            lastUpdated: DateTime(DateTime.now().year),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
      );
      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (celsius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: const WeatherStatusSuccess(),
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: 0),
            lastUpdated: DateTime(DateTime.now().year),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'status', const WeatherStatusSuccess())
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      const Temperature(value: weatherTemperature),
                    )
                    .having((w) => w.location, 'location', weatherLocation),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated weather (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          temperatureUnits: TemperatureUnits.fahrenheit,
          status: const WeatherStatusSuccess(),
          weather: Weather(
            location: weatherLocation,
            temperature: const Temperature(value: 0),
            lastUpdated: DateTime(DateTime.now().year),
            condition: weatherCondition,
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <Matcher>[
          isA<WeatherState>()
              .having((w) => w.status, 'status', const WeatherStatusSuccess())
              .having(
                (w) => w.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'lastUpdated', isNotNull)
                    .having((w) => w.condition, 'condition', weatherCondition)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      Temperature(value: weatherTemperature.toFahrenheit()),
                    )
                    .having((w) => w.location, 'location', weatherLocation),
              ),
        ],
      );
    });
    group('toggleUnits', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits updated units when status is not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature '
        'when status is success (celsius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: const WeatherStatusSuccess(),
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: WeatherCondition.rainy,
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: const WeatherStatusSuccess(),
            weather: Weather(
              location: weatherLocation,
              temperature: Temperature(value: weatherTemperature.toCelsius()),
              lastUpdated: DateTime(2020),
              condition: WeatherCondition.rainy,
            ),
          ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature '
        'when status is success (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: const WeatherStatusSuccess(),
          weather: Weather(
            location: weatherLocation,
            temperature: Temperature(value: weatherTemperature),
            lastUpdated: DateTime(2020),
            condition: WeatherCondition.rainy,
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: const WeatherStatusSuccess(),
            temperatureUnits: TemperatureUnits.fahrenheit,
            weather: Weather(
              location: weatherLocation,
              temperature: Temperature(
                value: weatherTemperature.toFahrenheit(),
              ),
              lastUpdated: DateTime(2020),
              condition: WeatherCondition.rainy,
            ),
          ),
        ],
      );
    });
  });
}
