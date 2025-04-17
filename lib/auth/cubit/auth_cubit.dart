import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<bool> {
  AuthCubit() : super(true);

  void changeAuth({required bool showLogin}) => emit(showLogin);

  
}
