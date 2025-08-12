import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern01/services/cloudinary_service.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc() : super(ImageInitial()) {
    on<SelectImageEvent>(_onSelectImage);
    on<UploadImageEvent>(_onUploadImage);
    on<LoadUserImageEvent>(_onLoadUserImage);
    on<ClearImageEvent>(_onClearImage);
    on<SaveDescriptionEvent>(_onSaveDescription);
  }

  void _onSelectImage(SelectImageEvent event, Emitter<ImageState> emit) {
    String? existingUrl;
    String? existingDescription;

    if (state is ImageLoaded) {
      final loadedState = state as ImageLoaded;
      existingUrl = loadedState.imageUrl;
      existingDescription = loadedState.description;
    }

    emit(
      ImageSelected(
        event.imageFile,
        existingUrl: existingUrl,
        description: existingDescription,
      ),
    );
  }

  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageUploading(event.imageFile));

    try {
      final imageUrl = await CloudinaryService.instance.uploadImage(
        event.imageFile,
      );

      if (imageUrl != null) {
        await _saveToFirestore(imageUrl, event.userEmail, event.description);
        emit(ImageUploaded(imageUrl, description: event.description));
      } else {
        emit(
          ImageUploadFailed(
            'Failed to upload to Cloudinary',
            selectedFile: event.imageFile,
          ),
        );
      }
    } catch (error) {
      emit(ImageUploadFailed(error.toString(), selectedFile: event.imageFile));
    }
  }

  Future<void> _onLoadUserImage(
    LoadUserImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('imagePost')
          .doc(event.userEmail)
          .get();

      if (doc.exists && doc.data()?['profileImageUrl'] != null) {
        final imageUrl = doc.data()!['profileImageUrl'] as String;
        final description = doc.data()?['description'] as String?;

        log(
          'Loaded existing image URL: $imageUrl with description: $description',
        );
        emit(ImageLoaded(imageUrl, description: description));
      } else {
        log('No existing image found for user: ${event.userEmail}');
        emit(ImageInitial());
      }
    } catch (error) {
      log('Error loading user image: $error');
      emit(ImageInitial());
    }
  }

  Future<void> _onSaveDescription(
    SaveDescriptionEvent event,
    Emitter<ImageState> emit,
  ) async {
    try {
      String? currentImageUrl;

      if (state is ImageLoaded) {
        currentImageUrl = (state as ImageLoaded).imageUrl;
      } else if (state is ImageUploaded) {
        currentImageUrl = (state as ImageUploaded).imageUrl;
      }

      if (currentImageUrl != null) {
        await _saveDescriptionToFirestore(
          currentImageUrl,
          event.userEmail,
          event.description,
        );
        emit(DescriptionSaved(currentImageUrl, event.description));
        emit(ImageLoaded(currentImageUrl, description: event.description));
      }
    } catch (error) {
      log('Error saving description: $error');
    }
  }

  void _onClearImage(ClearImageEvent event, Emitter<ImageState> emit) {
    if (state is ImageLoaded) {
      final loadedState = state as ImageLoaded;
      emit(
        ImageLoaded(loadedState.imageUrl, description: loadedState.description),
      );
    } else {
      emit(ImageInitial());
    }
  }

  Future<void> _saveToFirestore(
    String imageUrl,
    String userEmail,
    String? description,
  ) async {
    await FirebaseFirestore.instance
        .collection('imagePost')
        .doc(userEmail)
        .set({
          'profileImageUrl': imageUrl,
          'description': description ?? '',
          'email': userEmail,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> _saveDescriptionToFirestore(
    String imageUrl,
    String userEmail,
    String description,
  ) async {
    await FirebaseFirestore.instance
        .collection('imagePost')
        .doc(userEmail)
        .update({
          'description': description,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
  }
}
