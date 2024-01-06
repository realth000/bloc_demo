part of 'weather_cubit.dart';

/// Status of weather.
///
/// Because json_serializable does not support sealed classes, implement manually.
///
/// Extends [Equatable] for compare.
///
/// [value] is used like enum index for storage purpose.
sealed class WeatherStatus extends Equatable {
  const WeatherStatus();

  static Map<String, dynamic> toJson(WeatherStatus status) {
    const key = 'WeatherStatus';
    int value = -1;
    if (status is WeatherStatusInitial) {
      value = WeatherStatusInitial.value;
    } else if (status is WeatherStatusLoading) {
      value = WeatherStatusLoading.value;
    } else if (status is WeatherStatusSuccess) {
      value = WeatherStatusSuccess.value;
    } else if (status is WeatherStatusFailure) {
      value = WeatherStatusFailure.value;
    } else {
      throw Exception(
          'Unsupported WeatherStatus type. Check your code to ensure all status are handled');
    }

    return {key: value};
  }

  /// TODO: Reserve failed message when converting to json.
  static WeatherStatus fromJson(Map<String, dynamic> json) {
    return switch (json['WeatherStatus']) {
      WeatherStatusInitial.value => const WeatherStatusInitial(),
      WeatherStatusLoading.value => const WeatherStatusLoading(),
      WeatherStatusSuccess.value => const WeatherStatusSuccess(),
      WeatherStatusFailure.value => const WeatherStatusFailure.empty(),
      _ => throw Exception('invalid WeatherStatusValue'),
    };
  }
}

final class WeatherStatusInitial extends WeatherStatus {
  const WeatherStatusInitial();

  static const value = 0;

  @override
  List<Object?> get props => [value];
}

final class WeatherStatusLoading extends WeatherStatus {
  const WeatherStatusLoading();

  static const value = 1;

  @override
  List<Object?> get props => [value];
}

final class WeatherStatusSuccess extends WeatherStatus {
  const WeatherStatusSuccess();

  static const value = 2;

  @override
  List<Object?> get props => [value];
}

final class WeatherStatusFailure extends WeatherStatus {
  const WeatherStatusFailure(this.message);

  const WeatherStatusFailure.empty() : message = '';

  final String message;

  static const value = 3;

  @override
  String toString() {
    return 'WeatherStatusFailure { message: $message }';
  }

  @override
  List<Object?> get props => [value, message];
}

@JsonSerializable()
final class WeatherState extends Equatable {
  WeatherState({
    this.status = const WeatherStatusInitial(),
    this.temperatureUnits = TemperatureUnits.celsius,
    Weather? weather,
  }) : weather = weather ?? Weather.empty;

  factory WeatherState.fromJson(Map<String, dynamic> json) =>
      _$WeatherStateFromJson(json);

  WeatherState copyWith({
    WeatherStatus? status,
    TemperatureUnits? temperatureUnits,
    Weather? weather,
  }) {
    return WeatherState(
      status: status ?? this.status,
      temperatureUnits: temperatureUnits ?? this.temperatureUnits,
      weather: weather ?? this.weather,
    );
  }

  Map<String, dynamic> toJson() => _$WeatherStateToJson(this);

  @JsonKey(fromJson: WeatherStatus.fromJson, toJson: WeatherStatus.toJson)
  final WeatherStatus status;
  final Weather weather;
  final TemperatureUnits temperatureUnits;

  @override
  List<Object?> get props => [status, weather, temperatureUnits];
}
