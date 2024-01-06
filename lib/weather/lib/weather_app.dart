import 'package:bloc_demo/weather/lib/theme/cubit/theme_cubit.dart';
import 'package:bloc_demo/weather/lib/weather/view/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherApp extends StatelessWidget {
  const WeatherApp(WeatherRepository repo, {super.key}) : _repo = repo;

  final WeatherRepository _repo;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _repo,
      child: BlocProvider(
        create: (_) => ThemeCubit(),
        child: const WeatherAppView(),
      ),
    );
  }
}

class WeatherAppView extends StatelessWidget {
  const WeatherAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, Color>(
      builder: (context, color) {
        return const MaterialApp(
          home: WeatherPage(),
        );
      },
    );
  }
}
