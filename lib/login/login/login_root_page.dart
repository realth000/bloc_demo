import 'package:auth_repo/auth_repo.dart';
import 'package:bloc_demo/login/authentication/bloc/authentication_bloc.dart';
import 'package:bloc_demo/login/home/home.dart';
import 'package:bloc_demo/login/login/view/login_page.dart';
import 'package:bloc_demo/login/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repo/user_repo.dart';

class LoginRootPage extends StatefulWidget {
  const LoginRootPage({super.key});

  @override
  State<LoginRootPage> createState() => _LoginRootPageState();
}

class _LoginRootPageState extends State<LoginRootPage> {
  late final AuthRepo _authRepo;
  late final UserRepo _userRepo;

  @override
  void initState() {
    super.initState();
    _authRepo = AuthRepo();
    _userRepo = UserRepo();
  }

  @override
  void dispose() {
    _authRepo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _authRepo,
      child: BlocProvider(
        create: (_) {
          print('>>> create AuthBloc');
          return AuthBloc(
            authRepo: _authRepo,
            userRepo: _userRepo,
          );
        },
        child: const LoginRootView(),
      ),
    );
  }
}

class LoginRootView extends StatefulWidget {
  const LoginRootView({super.key});

  @override
  State<LoginRootView> createState() => _LoginRootViewState();
}

class _LoginRootViewState extends State<LoginRootView> {
  @override
  Widget build(BuildContext context) {
    print('>>> build LoginRootView');
    return MaterialApp(
      builder: (context, child) {
        final x = context.read<AuthBloc>();
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthAuthed():
                print('>>> push to HomePage');
                Navigator.of(context).pushAndRemoveUntil(
                  HomePage.route(),
                  (route) => false,
                );
              case AuthUnauthed():
                print('>>> push to LoginPage');
                Navigator.of(context).pushAndRemoveUntil(
                  LoginPage.route(),
                  (route) => false,
                );
              case AuthUnknown():
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    );
  }
}
