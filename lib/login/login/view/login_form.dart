import 'package:bloc_demo/login/login/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Used to show a snackbar if login submission fails.
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Authentication failed'),
              ),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _UsernameInput(),
            const SizedBox(width: 2, height: 2),
            _PasswordInput(),
            const SizedBox(width: 2, height: 2),
            _LoginButton(),
          ],
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) => prev.username != curr.username,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_usernameInput_textField'),
          decoration: InputDecoration(
            labelText: 'Username',
            errorText:
                state.username.displayError != null ? 'invalid username' : null,
          ),
          onChanged: (v) =>
              context.read<LoginBloc>().add(LoginUsernameChanged(v)),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) => prev.password != curr.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          decoration: InputDecoration(
            labelText: 'Password',
            errorText:
                state.password.displayError != null ? 'invalid password' : null,
          ),
          onChanged: (v) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(v)),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state.status.isInProgress) {
          return const CircularProgressIndicator();
        }
        return ElevatedButton(
          key: const Key('loginForm_continue_raisedButton'),
          onPressed: state.isValid
              ? () => context.read<LoginBloc>().add(const LoginSubmitted())
              : null,
          child: const Text('Login'),
        );
      },
    );
  }
}
