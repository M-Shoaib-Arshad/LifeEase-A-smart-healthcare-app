import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';

/// Free alternative to Firebase Storage using Cloudinary
/// Free tier: 25 GB storage + 25 GB bandwidth/month
/// Sign up: https://cloudinary.com/users/register/free
class CloudinaryStorageService {
  late CloudinaryPublic _cloudinary;
  bool _initialized = false;

  /// Initialize Cloudinary with your credentials
  /// Get these from: https://console.cloudinary.com/
  Future<void> initialize({
    required String cloudName,
    required String uploadPreset,
  }) async {
    _cloudinary = CloudinaryPublic(
      cloudName,
      uploadPreset,
      cache: false,
    );
    _initialized = true;
  }

  /// Upload user avatar (public access)
  /// Returns: Secure URL to the uploaded image
  Future<String> uploadAvatar(File file, String userId) async {
    if (!_initialized) {
      throw Exception('CloudinaryStorageService not initialized');
    }

    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'lifeease/avatars',
          publicId: userId,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Avatar upload failed: $e');
    }
  }

  /// Upload medical record (private access recommended)
  /// For HIPAA compliance, consider using Firebase Storage instead
  Future<String> uploadMedicalRecord(File file, String recordId) async {
    if (!_initialized) {
      throw Exception('CloudinaryStorageService not initialized');
    }

    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Auto,
          folder: 'lifeease/medical_records',
          publicId: recordId,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Medical record upload failed: $e');
    }
  }

  /// Upload prescription document
  Future<String> uploadPrescription(File file, String prescriptionId) async {
    if (!_initialized) {
      throw Exception('CloudinaryStorageService not initialized');
    }

    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Auto,
          folder: 'lifeease/prescriptions',
          publicId: prescriptionId,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Prescription upload failed: $e');
    }
  }

  /// Delete a file from Cloudinary
  Future<void> deleteFile(String publicId) async {
    if (!_initialized) {
      throw Exception('CloudinaryStorageService not initialized');
    }

    try {
      await _cloudinary.deleteFile(
        url: publicId,
        resourceType: CloudinaryResourceType.Image,
        invalidate: true,
      );
    } catch (e) {
      throw Exception('File deletion failed: $e');
    }
  }

  /// Generate a thumbnail URL (Cloudinary feature)
  String getThumbnailUrl(String url, {int width = 200, int height = 200}) {
    // Cloudinary URL transformation
    return url.replaceFirst(
      '/upload/',
      '/upload/w_$width,h_$height,c_fill/',
    );
  }
}

/// Example usage:
/// 
/// ```dart
/// // In main.dart or initialization
/// final cloudinaryService = CloudinaryStorageService();
/// await cloudinaryService.initialize(
///   cloudName: dotenv.env['CLOUDINARY_CLOUD_NAME']!,
///   uploadPreset: dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
/// );
/// 
/// // Upload avatar
/// final url = await cloudinaryService.uploadAvatar(imageFile, userId);
/// 
/// // Get thumbnail
/// final thumbnailUrl = cloudinaryService.getThumbnailUrl(url, width: 100, height: 100);
/// ```
