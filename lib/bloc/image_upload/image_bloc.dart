import 'dart:developer';
import 'dart:io';
import 'package:ToDoList/bloc/auth/auth_state.dart';
import 'package:ToDoList/services/cloudinary_service.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc() : super(ImageInitial()) {
    on<SelectImageEvent>(_onSelectImage);
    on<UploadImageEvent>(_onUploadImage);
    on<UploadPostEvent>(_onUploadPost);
    on<LoadUserImageEvent>(_onLoadUserImage);
    on<ClearImageEvent>(_onClearImage);
    on<SaveDescriptionEvent>(_onSaveDescription);
    on<DeleteImageEvent>(_onDeleteCard);
    on<EditPostEvent>(_onEditPost);
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

  Future<void> _onEditPost(
    EditPostEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageUploading(event.newImageFile));
    String? imageUrl;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (event.newImageFile != null) {
      emit(ImageUploading(event.newImageFile!));
      imageUrl = await CloudinaryService.instance.uploadImage(
        event.newImageFile!,
      );
      if (imageUrl == null) {
        emit(
          ImageUploadFailed(
            'Failed to upload to Cloudinary',
            selectedFile: event.newImageFile!,
          ),
        );
        return;
      }
    } else {
      if (state is ImageLoaded) {
        imageUrl = (state as ImageLoaded).imageUrl;
      } else if (state is ImageUploaded) {
        imageUrl = (state as ImageUploaded).imageUrl;
      } else {
        final postRef = FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('posts')
            .doc(event.postId);
        final doc = await postRef.get();
        if (doc.exists && doc.data()?['uploadUrl'] != null) {
          imageUrl = doc.data()!['uploadUrl'] as String;
        }
      }
    }

    final postRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('posts')
        .doc(event.postId);

    final updateData = {
      'uploadDescription': event.newDescription,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (imageUrl != null) {
      updateData['uploadUrl'] = imageUrl;
    }

    await postRef.update(updateData);

    if (imageUrl != null) {
      emit(ImageUploaded(imageUrl, description: event.newDescription));
    } else {
      emit(ImageLoaded('', description: event.newDescription));
    }
  }

  Future<void> _onUploadPost(
    UploadPostEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageUploading(event.imageFile));

    try {
      final imageUrl = await CloudinaryService.instance.postImage(
        event.imageFile,
      );

      if (imageUrl != null) {
        await _uploadToFirestore(imageUrl, event.description);
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
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
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
        final uid = FirebaseAuth.instance.currentUser?.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'description': event.description,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
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
      final authState = state as AuthSuccess;

      emit(
        ImageLoaded(loadedState.imageUrl, description: loadedState.description),
      );
      try {
        _deleteFromFirestore(
          loadedState.imageUrl,
          authState.email,
          loadedState.description,
        );
      } catch (e) {
        emit(ImageInitial());
        log("Error deleting the card");
      }
    } else {
      emit(ImageInitial());
    }
  }

  void _onDeleteCard(DeleteImageEvent event, Emitter<ImageState> emit) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('posts')
            .doc(event.postId)
            .delete();
      }
      emit(ImageInitial());
    } catch (e) {
      log("Failed to delete post: $e");
    }
  }

  void _deleteFromFirestore(
    String postId,
    String userEmail,
    String? description,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('posts')
          .doc(postId)
          .delete();
    }
  }

  // Future<void> _editPostFirestore(
  //   String docId,
  //   String uploadUrl,
  //   String? uploadDescription,
  // ) async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection(evet)
  //       .add({
  //         'uploadUrl': uploadUrl,
  //         'uploadDescription': uploadDescription,
  //         'timestamp': FieldValue.serverTimestamp(),
  //       });
  // }

  Future<void> _uploadToFirestore(
    String uploadUrl,
    String? uploadDescription,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('posts')
        .add({
          'uploadUrl': uploadUrl,
          'uploadDescription': uploadDescription,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _saveToFirestore(
    String imageUrl,
    String userEmail,
    String? profileDescription,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'profileImageUrl': imageUrl,
      'description': profileDescription ?? '',

      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
