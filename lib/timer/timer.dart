export 'bloc/timer_bloc.dart';
export 'view/timer_page.dart';

class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x - 1);
  }
}
