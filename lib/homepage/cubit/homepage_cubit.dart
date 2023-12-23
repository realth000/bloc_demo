import 'package:flutter_bloc/flutter_bloc.dart';

class HomepageCubit extends Cubit<int> {
  HomepageCubit() : super(0);

  void pageChanged(int index) => emit(index);
}
