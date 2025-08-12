# Complete BLoC Implementation Guide

## What You Need to Add to pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3  # Add this line
  equatable: ^2.0.5     # Optional but recommended for comparing states
```

Run: `flutter pub get`

## How BLoC Works - Step by Step

### 1. **User Interaction (UI)**
```dart
// User clicks login button
ElevatedButton(
  onPressed: () {
    // Send event to BLoC
    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password)
    );
  },
  child: Text('Login'),
)
```

### 2. **Event Sent to BLoC**
```dart
// Event defines WHAT happened
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  // Constructor...
}
```

### 3. **BLoC Processes Event**
```dart
// BLoC receives event and processes it
Future<void> _onAuthLoginRequested(
  AuthLoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());  // Tell UI we're loading
  
  try {
    // Call repository to do actual work
    final result = await _authRepository.login(event.email, event.password);
    
    if (result.role == 'admin') {
      emit(AuthenticatedAsAdmin(email: result.email));  // Tell UI success
    } else {
      emit(AuthenticatedAsUser(email: result.email));   // Tell UI success
    }
  } catch (e) {
    emit(AuthError(message: e.toString()));  // Tell UI about error
  }
}
```

### 4. **UI Reacts to State Change**
```dart
// UI listens to state changes and rebuilds automatically
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();  // Show loading
    }
    
    if (state is AuthError) {
      return Text(state.message);  // Show error
    }
    
    if (state is AuthenticatedAsAdmin) {
      return AdminScreen();  // Navigate to admin screen
    }
    
    if (state is AuthenticatedAsUser) {
      return UserScreen();  // Navigate to user screen
    }
    
    return LoginForm();  // Show login form
  },
)
```

## Complete Implementation Steps

### Step 1: Add Dependencies
Add flutter_bloc to pubspec.yaml and run `flutter pub get`

### Step 2: Define Events (What can happen?)
```dart
abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent { /* email, password */ }
class AuthSignupRequested extends AuthEvent { /* email, password, role */ }
class AuthLogoutRequested extends AuthEvent {}
```

### Step 3: Define States (What are the possible conditions?)
```dart
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthenticatedAsAdmin extends AuthState { /* user data */ }
class AuthenticatedAsUser extends AuthState { /* user data */ }
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState { /* error message */ }
```

### Step 4: Create Repository (Data operations)
```dart
class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    // Firebase login logic here
  }
  
  Future<UserModel> signup(String email, String password, String role) async {
    // Firebase signup logic here
  }
  
  Future<void> logout() async {
    // Firebase logout logic here
  }
}
```

### Step 5: Create BLoC (Event processor)
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  
  AuthBloc({required AuthRepository repository}) 
    : _repository = repository,
      super(AuthInitial()) {
    
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }
  
  // Event handlers here...
}
```

### Step 6: Provide BLoC to Widget Tree
```dart
// In your main.dart or app.dart
BlocProvider(
  create: (context) => AuthBloc(repository: AuthRepository()),
  child: MyApp(),
)
```

### Step 7: Use BLoC in UI
```dart
// Send events
context.read<AuthBloc>().add(AuthLoginRequested(email: email, password: password));

// Listen to states
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    // React to different states
  },
)
```

## Benefits of This Approach

1. **Separation of Concerns**: UI only handles display, BLoC handles logic
2. **Testability**: You can test BLoC without UI
3. **Maintainability**: Easy to modify business logic without touching UI
4. **State Management**: Single source of truth for app state
5. **Predictability**: Clear flow: Event → BLoC → State → UI

## Your Next Steps

1. **Add flutter_bloc dependency**
2. **Start with one BLoC (AuthBLoC)**
3. **Convert your register.dart to use BLoC**
4. **Test the flow**
5. **Add TaskBLoC later**

## Common Beginner Mistakes to Avoid

1. **Don't put UI logic in BLoC** - BLoC should only handle business logic
2. **Don't call repository directly from UI** - Always go through BLoC
3. **Don't forget to provide BLoC to widget tree** - Use BlocProvider
4. **Don't mix setState with BLoC** - Choose one approach

## When to Use What

- **BlocBuilder**: When you want to rebuild UI based on state
- **BlocListener**: When you want to perform side effects (navigation, show snackbar)
- **BlocConsumer**: When you need both building and listening
- **BlocProvider**: To provide BLoC to widget tree
- **RepositoryProvider**: To provide repository to BLoC

This is a complete foundation for implementing BLoC in your app!
