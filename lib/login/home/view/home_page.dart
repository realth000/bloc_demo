import 'package:bloc_demo/login/authentication/bloc/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Builder(
              builder: (BuildContext context) {
                // Use "select" to trigger update only if uid changes.
                final uid = context
                    .select<AuthBloc, String>((bloc) => bloc.state.user.id);
                return Text('UID: $uid');
              },
            ),
            ElevatedButton(
              child: const Text('Logout'),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
      ),
    );
  }
}
