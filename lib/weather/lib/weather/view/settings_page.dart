import 'package:bloc_demo/weather/lib/weather/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static route(WeatherCubit cubit) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          BlocBuilder<WeatherCubit, WeatherState>(
            buildWhen: (prev, curr) =>
                prev.temperatureUnits != curr.temperatureUnits,
            builder: (context, state) {
              return SwitchListTile(
                title: const Text('Temperature Unit'),
                isThreeLine: true,
                subtitle: const Text('Use temperature units'),
                value: state.temperatureUnits.isCelsius,
                onChanged: (_) => context.read<WeatherCubit>().toggleUnits(),
              );
            },
          ),
        ],
      ),
    );
  }
}
