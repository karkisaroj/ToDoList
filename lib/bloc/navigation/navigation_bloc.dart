import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<NavigateToTask>(_onNavigateToTasks);
    on<NavigateToProfile>(_onNavigateToProfile);
    on<NavigateToSettings>(_onNavigateToSettings);
    on<TabSelected>(_onTabSelected);
    on<DrawerNavigationRequested>(_onDrawerNavigationRequested);
    on<ResetNavigation>(_onResetNavigation);
  }

  void _onNavigateToTasks(NavigateToTask event, Emitter<NavigationState> emit) {
    emit(TaskPageSelected());
  }

  void _onNavigateToProfile(
    NavigateToProfile event,
    Emitter<NavigationState> emit,
  ) {
    emit(ProfilePageSelected());
  }

  void _onNavigateToSettings(
    NavigateToSettings event,
    Emitter<NavigationState> emit,
  ) {
    emit(SettingPageSelected());
  }

  void _onTabSelected(TabSelected event, Emitter<NavigationState> emit) {
    switch (event.tabIndex) {
      case 0:
        emit(TaskPageSelected());
        break;
      case 1:
        emit(ProfilePageSelected());
        break;
      case 2:
        emit(SettingPageSelected());
        break;
      case 3:
        emit(TaskPageSelected());
        break;
      default:
        emit(TaskPageSelected());
    }
  }

  void _onDrawerNavigationRequested(
    DrawerNavigationRequested event,
    Emitter<NavigationState> emit,
  ) {
    emit(TabNavigated(event.pageIndex));
  }

  void _onResetNavigation(
    ResetNavigation event,
    Emitter<NavigationState> emit,
  ) {
    emit(NavigationInitial());
  }
}
