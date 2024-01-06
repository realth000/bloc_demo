import 'package:bloc_demo/weather/lib/theme/cubit/theme_cubit.dart';
import 'package:bloc_demo/weather/lib/weather/cubit/weather_cubit.dart';
import 'package:bloc_demo/weather/lib/weather/view/search_page.dart';
import 'package:bloc_demo/weather/lib/weather/view/settings_page.dart';
import 'package:bloc_demo/weather/lib/weather/widgets/weather_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WeatherCubit(context.read<WeatherRepository>()),
      child: const WeatherView(),
    );
  }
}

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context)
                  .push(SettingsPage.route(context.read<WeatherCubit>()));
            },
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<WeatherCubit, WeatherState>(
          listener: (context, state) {
            if (state.status is WeatherStatusSuccess) {
              context.read<ThemeCubit>().updateTheme(state.weather);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case WeatherStatusInitial():
                return const WeatherEmpty();
              case WeatherStatusLoading():
                return const WeatherLoading();
              case WeatherStatusSuccess():
                return WeatherPopulated(
                  weather: state.weather,
                  units: state.temperatureUnits,
                  onRefresh: () {
                    return context.read<WeatherCubit>().refreshWeather();
                  },
                );
              case WeatherStatusFailure():
                return const WeatherError();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search, semanticLabel: 'Search'),
        onPressed: () async {
          final city = await Navigator.of(context).push(SearchPage.route());
          if (!mounted || city == null) {
            return;
          }
          await context.read<WeatherCubit>().fetchWeather(city);
        },
      ),
    );
  }
}
