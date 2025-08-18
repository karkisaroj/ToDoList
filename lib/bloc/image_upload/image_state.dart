part of 'image_bloc.dart';

@immutable
sealed class ImageState {}

final class ImageInitial extends ImageState {}

final class ImageSelected extends ImageState {
  final File selectedFile;
  final String? existingUrl;
  final String? description;

  ImageSelected(this.selectedFile, {this.existingUrl, this.description});
}

final class ImageUploading extends ImageState {
  final File? selectedFile;

  ImageUploading([this.selectedFile]);
}

final class ImageUploaded extends ImageState {
  final String imageUrl;
  final String? description;
  ImageUploaded(this.imageUrl, {this.description});
}

final class ImageLoaded extends ImageState {
  final String imageUrl;
  final String? description;

  ImageLoaded(this.imageUrl, {this.description});
}

final class ImageUploadFailed extends ImageState {
  final String error;
  final File? selectedFile;

  ImageUploadFailed(this.error, {this.selectedFile});
}

final class DescriptionSaved extends ImageState {
  final String imageUrl;
  final String description;

  DescriptionSaved(this.imageUrl, this.description);
}
