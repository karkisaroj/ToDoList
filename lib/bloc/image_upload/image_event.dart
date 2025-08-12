part of 'image_bloc.dart';

@immutable
sealed class ImageEvent {}

class UploadImageEvent extends ImageEvent {
  final File imageFile;
  final String userEmail;
  final String? description;

  UploadImageEvent(this.imageFile, this.userEmail, {this.description});
}

class LoadUserImageEvent extends ImageEvent {
  final String userEmail;

  LoadUserImageEvent(this.userEmail);
}

class SelectImageEvent extends ImageEvent {
  final File imageFile;

  SelectImageEvent(this.imageFile);
}

class ClearImageEvent extends ImageEvent {}

class SaveDescriptionEvent extends ImageEvent {
  final String description;
  final String userEmail;

  SaveDescriptionEvent(this.description, this.userEmail);
}
