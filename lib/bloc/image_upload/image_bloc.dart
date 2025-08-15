import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intern01/services/cloudinary_service.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  // Add post upload event handler
  void _onUploadPost(UploadPostEvent event, Emitter<ImageState> emit) async {
    emit(ImageUploading(event.imageFile));
    try {
      final imageUrl = await CloudinaryService.instance.postImage(
        event.imageFile,
      );
      if (imageUrl != null) {
        final user = await _getCurrentUser();
        if (user != null) {
          await FirebaseFirestore.instance.collection('posts').add({
            'imageUrl': imageUrl,
            'description': event.description ?? '',
            'uid': user.uid,
            'email': user.email,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
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

  ImageBloc() : super(ImageInitial()) {
    on<SelectImageEvent>(_onSelectImage);
    on<UploadImageEvent>(_onUploadImage);
    on<UploadPostEvent>(_onUploadPost);
    on<LoadUserImageEvent>(_onLoadUserImage);
    on<ClearImageEvent>(_onClearImage);
    on<SaveDescriptionEvent>(_onSaveDescription);
    on<DeleteImageEvent>(_onDeleteImage);
  }

  Future<void> _onDeleteImage(
    DeleteImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(event.postId)
          .delete();
      emit(ImageInitial());
    } catch (e) {
      log('Failed to delete post: ' + e.toString());
    }
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
        final user = await _getCurrentUser();
        if (user != null) {
          await _saveToFirestore(
            imageUrl,
            user.uid,
            event.description,
            user.email,
          );
        }
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
      final user = await _getCurrentUser();
      if (user == null) {
        emit(ImageInitial());
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()?['profileImageUrl'] != null) {
        final imageUrl = doc.data()!['profileImageUrl'] as String;
        final description = doc.data()?['description'] as String?;

        log(
          'Loaded existing image URL: $imageUrl with description: $description',
        );
        emit(ImageLoaded(imageUrl, description: description));
      } else {
        log('No existing image found for user: ${user.uid}');
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
        final user = await _getCurrentUser();
        if (user != null) {
          await _saveDescriptionToFirestore(
            currentImageUrl,
            user.uid,
            event.description,
          );
        }
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
    String uid,
    String? description,
    String? email,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'profileImageUrl': imageUrl,
      'description': description ?? '',
      'email': email ?? '',
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _saveDescriptionToFirestore(
    String imageUrl,
    String uid,
    String description,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'description': description,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<dynamic> _getCurrentUser() async {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (e) {
      log('Error getting current user: ' + e.toString());
      return null;
    }
  }
}
