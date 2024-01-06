import 'package:bloc_demo/counter/view/counter_page.dart';
import 'package:bloc_demo/homepage/cubit/cubit.dart';
import 'package:bloc_demo/infinite_list/posts/view/view.dart';
import 'package:bloc_demo/login/login/login_root_page.dart';
import 'package:bloc_demo/timer/timer.dart';
import 'package:bloc_demo/weather/lib/weather_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class _ScreenItem {
  _ScreenItem({
    required this.name,
    required this.icon,
    required this.selectedIcon,
    required this.body,
  });

  final String name;
  final IconData icon;
  final IconData selectedIcon;
  final Widget body;
}

class HomepageView extends StatelessWidget {
  HomepageView({super.key});

  final _screens = [
    _ScreenItem(
      name: 'Counter',
      icon: Icons.back_hand_outlined,
      selectedIcon: Icons.back_hand,
      body: const CounterPage(),
    ),
    _ScreenItem(
      name: 'Timer',
      icon: Icons.timer_outlined,
      selectedIcon: Icons.timer,
      body: const TimerPage(),
    ),
    _ScreenItem(
      name: 'Infinite List',
      icon: Icons.list_outlined,
      selectedIcon: Icons.list,
      body: const PostsPage(),
    ),
    _ScreenItem(
      name: 'Login',
      icon: Icons.login_outlined,
      selectedIcon: Icons.login,
      body: const LoginRootPage(),
    ),
    _ScreenItem(
      name: 'Weather',
      icon: Icons.wb_sunny_outlined,
      selectedIcon: Icons.wb_sunny,
      body: WeatherApp(WeatherRepository()),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomepageCubit, int>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(_screens.elementAt(state).name)),
          body: _screens.elementAt(state).body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: state,
            onDestinationSelected: (index) {
              context.read<HomepageCubit>().pageChanged(index);
            },
            destinations: _screens
                .map(
                  (e) => NavigationDestination(
                    label: e.name,
                    icon: Icon(e.icon),
                    selectedIcon: Icon(e.selectedIcon),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
