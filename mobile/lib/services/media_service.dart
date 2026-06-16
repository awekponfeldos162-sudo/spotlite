import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class MediaService {
  final _client = Supabase.instance.client;
  final _picker = ImagePicker();
  final _uuid = const Uuid();
  final _bucket = 'projets_talents';

  // Sélectionner et uploader une image
  Future<String?> pickAndUploadImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file == null) return null;
    return _upload(File(file.path), 'image');
  }

  // Sélectionner et uploader une vidéo
  Future<String?> pickAndUploadVideo() async {
    final file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 3),
    );
    if (file == null) return null;
    return _upload(File(file.path), 'video');
  }

  // Upload vers Supabase Storage
  Future<String?> _upload(File file, String type) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$ext';
      final path = '$type/$fileName';

      await _client.storage
          .from(_bucket)
          .upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final url = _client.storage.from(_bucket).getPublicUrl(path);
      return url;
    } catch (e) {
      return null;
    }
  }
}
