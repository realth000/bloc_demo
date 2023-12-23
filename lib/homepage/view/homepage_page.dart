import 'package:bloc_demo/homepage/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomepagePage extends StatelessWidget {
  const HomepagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomepageCubit(),
      child: HomepageView(),
    );
  }
}
