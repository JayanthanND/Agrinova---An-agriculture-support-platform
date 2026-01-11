import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {
  final ImagePicker _imagePicker = ImagePicker();

  // Method to pick and crop image
  Future<File?> pickAndCropImage({required ImageSource source}) async {
    // Pick image from gallery or camera
    final XFile? pickedImage = await _imagePicker.pickImage(source: source);
    if (pickedImage == null) return null;

    // Crop the picked image
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    // Return the cropped file
    return croppedImage != null ? File(croppedImage.path) : null;
  }

  // Method to upload image to Firebase Storage and return the download URL
  Future<String?> uploadImage(File imageFile, String folderName) async {
    try {
      // Generate a unique file name using timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('$folderName/$fileName');

      // Upload the image file to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload task to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
