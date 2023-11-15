import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { home, announce, manage, profile }

class AppNavigatorCubit extends Cubit<AppTab> {
  AppNavigatorCubit() : super(AppTab.home);

  void showHome() => emit(AppTab.home);
  void showAnnounce() => emit(AppTab.announce);
  void showManage() => emit(AppTab.manage);
  void showProfile() => emit(AppTab.profile);
}
