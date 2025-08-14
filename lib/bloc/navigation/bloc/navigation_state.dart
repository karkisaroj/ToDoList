part of 'navigation_bloc.dart';

@immutable
sealed class NavigationState {
  final int currentIndex;
  const NavigationState({required this.currentIndex});
}

final class NavigationInitial extends NavigationState {
  const NavigationInitial() : super(currentIndex: 0);
}

final class TaskPageSelected extends NavigationState {
  const TaskPageSelected() : super(currentIndex: 0);
}

final class ProfilePageSelected extends NavigationState {
  const ProfilePageSelected() : super(currentIndex: 1);
}

final class SettingPageSelected extends NavigationState {
  const SettingPageSelected() : super(currentIndex: 2);
}

final class TabNavigated extends NavigationState {
  const TabNavigated(int index) : super(currentIndex: index);
}
