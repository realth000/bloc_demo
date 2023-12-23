import 'package:bloc/bloc.dart';
import 'package:bloc_demo/app.dart';
import 'package:bloc_demo/observer.dart';
import 'package:flutter/material.dart';

void main() {
  Bloc.observer = const Observer();
  runApp(const App());
}
