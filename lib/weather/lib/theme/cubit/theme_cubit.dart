import 'package:bloc_demo/weather/lib/weather/models/models.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:weather_repository/weather_repository.dart'
    show WeatherCondition;

extension on Weather {
  Color get toColor {
    return switch (condition) {
      WeatherCondition.clear => Colors.yellow,
      WeatherCondition.snowy => Colors.lightBlueAccent,
      WeatherCondition.cloudy => Colors.blueGrey,
      WeatherCondition.rainy => Colors.indigoAccent,
      WeatherCondition.unknown => ThemeCubit.defaultColor,
    };
  }
}

class ThemeCubit extends HydratedCubit<Color> {
  ThemeCubit() : super(defaultColor);

  static const defaultColor = Color(0xFF2196F3);

  void updateTheme(Weather? weather) {
    if (weather != null) {
      emit(weather.toColor);
    }
  }

  @override
  Color fromJson(Map<String, dynamic> json) {
    final v = int.tryParse(json['color']);
    if (v == null) {
      return Color(defaultColor.value);
    }
    return Color(v);
  }

  @override
  Map<String, dynamic> toJson(Color state) {
    return {'color': '${state.value}'};
  }
}
