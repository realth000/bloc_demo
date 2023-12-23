import 'package:bloc/bloc.dart';

class Observer extends BlocObserver {
  const Observer();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}
