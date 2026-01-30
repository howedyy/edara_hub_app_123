import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:edara_hub_app_123/core/services/firebase_service.dart';

/// Service for handling Firebase Storage operations.
/// 
/// This service provides methods for:
/// - Uploading images to Firebase Storage
/// - Uploading videos to Firebase Storage
/// - Retrieving file URLs
/// - Deleting files from storage
/// 
/// All methods return results wrapped in a Map with success status and data/error messages.
class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseService.storage;

  // Storage paths
  static const String imagesPath = 'events/images';
  static const String videosPath = 'events/videos';

  /// Uploads an image file to Firebase Storage.
  /// 
  /// Parameters:
  /// - file: The image file to upload
  /// - fileName: Optional custom file name (defaults to timestamp-based name)
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if upload was successful
  /// - message: String with success or error message
  /// - data: Map with file URL and metadata if successful, null otherwise
  Future<Map<String, dynamic>> uploadImage({
    required File file,
    String? fileName,
  }) async {
    try {
      // Generate file name if not provided
      final String uploadFileName = fileName ?? 
          'image_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      // Create reference to storage location
      final Reference ref = _storage.ref().child('$imagesPath/$uploadFileName');
      
      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );
      
      // Upload file
      final UploadTask uploadTask = ref.putFile(file, metadata);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Get file metadata
      final FullMetadata fileMetadata = await snapshot.ref.getMetadata();
      
      return {
        'success': true,
        'message': 'Image uploaded successfully',
        'data': {
          'url': downloadUrl,
          'path': ref.fullPath,
          'name': uploadFileName,
          'size': fileMetadata.size,
          'contentType': fileMetadata.contentType,
          'uploaded_at': fileMetadata.customMetadata?['uploaded_at'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload image: $e',
        'data': null,
      };
    }
  }

  /// Uploads a video file to Firebase Storage.
  /// 
  /// Parameters:
  /// - file: The video file to upload
  /// - fileName: Optional custom file name (defaults to timestamp-based name)
  /// - title: Optional video title
  /// - description: Optional video description
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if upload was successful
  /// - message: String with success or error message
  /// - data: Map with file URL and metadata if successful, null otherwise
  Future<Map<String, dynamic>> uploadVideo({
    required File file,
    String? fileName,
    String? title,
    String? description,
  }) async {
    try {
      // Generate file name if not provided
      final String uploadFileName = fileName ?? 
          'video_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      // Create reference to storage location
      final Reference ref = _storage.ref().child('$videosPath/$uploadFileName');
      
      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'video/mp4',
        customMetadata: {
          'uploaded_at': DateTime.now().toIso8601String(),
          if (title != null) 'title': title,
          if (description != null) 'description': description,
        },
      );
      
      // Upload file
      final UploadTask uploadTask = ref.putFile(file, metadata);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Get file metadata
      final FullMetadata fileMetadata = await snapshot.ref.getMetadata();
      
      return {
        'success': true,
        'message': 'Video uploaded successfully',
        'data': {
          'url': downloadUrl,
          'path': ref.fullPath,
          'name': uploadFileName,
          'size': fileMetadata.size,
          'contentType': fileMetadata.contentType,
          'title': fileMetadata.customMetadata?['title'],
          'description': fileMetadata.customMetadata?['description'],
          'uploaded_at': fileMetadata.customMetadata?['uploaded_at'],
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload video: $e',
        'data': null,
      };
    }
  }

  /// Retrieves the download URL for a file.
  /// 
  /// Parameters:
  /// - filePath: The full path to the file in Firebase Storage
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if retrieval was successful
  /// - message: String with success or error message
  /// - data: Download URL if successful, null otherwise
  Future<Map<String, dynamic>> getFileUrl(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      final String downloadUrl = await ref.getDownloadURL();
      
      return {
        'success': true,
        'message': 'File URL retrieved successfully',
        'data': downloadUrl,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve file URL: $e',
        'data': null,
      };
    }
  }

  /// Deletes a file from Firebase Storage.
  /// 
  /// Parameters:
  /// - filePath: The full path to the file in Firebase Storage
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if deletion was successful
  /// - message: String with success or error message
  Future<Map<String, dynamic>> deleteFile(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      await ref.delete();
      
      return {
        'success': true,
        'message': 'File deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete file: $e',
      };
    }
  }

  /// Gets metadata for a file.
  /// 
  /// Parameters:
  /// - filePath: The full path to the file in Firebase Storage
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if retrieval was successful
  /// - message: String with success or error message
  /// - data: File metadata if successful, null otherwise
  Future<Map<String, dynamic>> getFileMetadata(String filePath) async {
    try {
      final Reference ref = _storage.ref().child(filePath);
      final FullMetadata metadata = await ref.getMetadata();
      
      return {
        'success': true,
        'message': 'File metadata retrieved successfully',
        'data': {
          'name': metadata.name,
          'bucket': metadata.bucket,
          'fullPath': metadata.fullPath,
          'size': metadata.size,
          'contentType': metadata.contentType,
          'timeCreated': metadata.timeCreated?.toIso8601String(),
          'updated': metadata.updated?.toIso8601String(),
          'customMetadata': metadata.customMetadata,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve file metadata: $e',
        'data': null,
      };
    }
  }

  /// Lists all files in a directory.
  /// 
  /// Parameters:
  /// - path: The directory path in Firebase Storage
  /// - maxResults: Maximum number of results to return (default: 100)
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if listing was successful
  /// - message: String with success or error message
  /// - data: List of file references if successful, empty list otherwise
  Future<Map<String, dynamic>> listFiles({
    required String path,
    int maxResults = 100,
  }) async {
    try {
      final Reference ref = _storage.ref().child(path);
      final ListResult result = await ref.list(ListOptions(maxResults: maxResults));
      
      final List<Map<String, dynamic>> files = [];
      for (final Reference fileRef in result.items) {
        final String url = await fileRef.getDownloadURL();
        files.add({
          'name': fileRef.name,
          'fullPath': fileRef.fullPath,
          'url': url,
        });
      }
      
      return {
        'success': true,
        'message': 'Files listed successfully',
        'data': files,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to list files: $e',
        'data': [],
      };
    }
  }

  /// Uploads a file with progress tracking.
  /// 
  /// Parameters:
  /// - file: The file to upload
  /// - path: The storage path (e.g., 'events/images' or 'events/videos')
  /// - fileName: Optional custom file name
  /// - onProgress: Callback function to track upload progress (0.0 to 1.0)
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if upload was successful
  /// - message: String with success or error message
  /// - data: Map with file URL and metadata if successful, null otherwise
  Future<Map<String, dynamic>> uploadFileWithProgress({
    required File file,
    required String path,
    String? fileName,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Generate file name if not provided
      final String uploadFileName = fileName ?? 
          'file_${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      
      // Create reference to storage location
      final Reference ref = _storage.ref().child('$path/$uploadFileName');
      
      // Upload file
      final UploadTask uploadTask = ref.putFile(file);
      
      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return {
        'success': true,
        'message': 'File uploaded successfully',
        'data': {
          'url': downloadUrl,
          'path': ref.fullPath,
          'name': uploadFileName,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upload file: $e',
        'data': null,
      };
    }
  }
}
