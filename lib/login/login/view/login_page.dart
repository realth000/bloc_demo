import 'package:bloc_demo/login/login/bloc/login_bloc.dart';
import 'package:bloc_demo/login/login/view/login_form.dart';
import 'package:bloc_demo/packages/auth_repo/lib/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    print('>>> build LoginPage');
    return BlocProvider(
      create: (context) {
        // Lookup the instance of AuthRepo via the context.
        return LoginBloc(
          authRepo: RepositoryProvider.of<AuthRepo>(context),
        );
      },
      child: const LoginForm(),
    );
  }
}
