part of 'navigation_bloc.dart';

@immutable
sealed class NavigationEvent {}

class NavigateToTask extends NavigationEvent {}

class NavigateToProfile extends NavigationEvent {}

class NavigateToSettings extends NavigationEvent {}

class TabSelected extends NavigationEvent {
  final int tabIndex;
  TabSelected(this.tabIndex);
}

class DrawerNavigationRequested extends NavigationEvent {
  final int pageIndex;
  DrawerNavigationRequested(this.pageIndex);
}

class ResetNavigation extends NavigationEvent {}
