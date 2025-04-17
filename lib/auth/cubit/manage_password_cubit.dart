import 'package:flutter_bloc/flutter_bloc.dart';

class ManagePasswordCubit extends Cubit<bool> {
  // ManagePasswordCubit(super.initialState); // dynamic initial state
  ManagePasswordCubit() : super(true); // fixed state

  void changeScreen({required bool showForgotPassword}) {
    emit(showForgotPassword);
  }
  
}