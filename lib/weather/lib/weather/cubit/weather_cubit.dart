import 'package:bloc_demo/weather/lib/weather/models/weather.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherRepository;

part 'weather_cubit.g.dart';
part 'weather_state.dart';

extension TemperatureX on double {
  double toFahrenheit() => (this * 9 / 5) + 32;

  double toCelsius() => (this - 32) * 5 / 9;
}

/// [HydratedCubit] manages storage.
class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final WeatherRepository _weatherRepository;

  Future<void> fetchWeather(String? city) async {
    if (city == null || city.trim().isEmpty) {
      return;
    }
    emit(state.copyWith(status: const WeatherStatusLoading()));

    try {
      // Call the implementation in repository.
      final weather =
          Weather.fromRepository(await _weatherRepository.getWeather(city));
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
            status: const WeatherStatusSuccess(),
            temperatureUnits: units,
            weather: weather.copyWith(temperature: Temperature(value: value))),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: WeatherStatusFailure(e.toString())));
    }
  }

  Future<void> refreshWeather() async {
    if (state.status is! WeatherStatusSuccess ||
        state.weather == Weather.empty) {
      return;
    }

    try {
      final weather = Weather.fromRepository(
          await _weatherRepository.getWeather(state.weather.location));
      final units = state.temperatureUnits;
      final value = units.isFahrenheit
          ? weather.temperature.value.toFahrenheit()
          : weather.temperature.value;

      emit(
        state.copyWith(
          status: const WeatherStatusSuccess(),
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    } on Exception {
      emit(state);
    }
  }

  /// Update weather settings.
  void toggleUnits() {
    final units = state.temperatureUnits.isFahrenheit
        ? TemperatureUnits.celsius
        : TemperatureUnits.fahrenheit;

    if (state.status is! WeatherStatusSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }

    final weather = state.weather;
    if (weather != Weather.empty) {
      final temperature = weather.temperature;
      final value = units.isCelsius
          ? temperature.value.toCelsius()
          : temperature.value.toFahrenheit();
      emit(
        state.copyWith(
          temperatureUnits: units,
          weather: weather.copyWith(temperature: Temperature(value: value)),
        ),
      );
    }
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}
