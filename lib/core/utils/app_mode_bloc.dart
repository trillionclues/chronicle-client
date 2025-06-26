import 'package:chronicle/core/utils/app_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppModeBloc extends Bloc<AppModeEvent, AppMode> {
  AppModeBloc() : super(AppMode.collaborativeWriting) {
    on<ChangeAppModeEvent>((event, emit) => emit(event.newMode));
  }
}

abstract class AppModeEvent {}

class ChangeAppModeEvent extends AppModeEvent {
  final AppMode newMode;
  ChangeAppModeEvent(this.newMode);
}
