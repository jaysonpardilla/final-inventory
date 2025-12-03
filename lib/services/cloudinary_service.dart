import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class CloudinaryService {
  Future<String?> uploadFile(File file) async {
    try {
      final uri = Uri.parse(Config.cloudinaryUploadUrl);

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path))
        ..fields['upload_preset'] = Config.cloudinaryUploadPreset;

      final streamedResp = await request.send();
      final resp = await http.Response.fromStream(streamedResp);

      print("🔹 Cloudinary response code: ${resp.statusCode}");
      print("🔹 Cloudinary response body: ${resp.body}");

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        return body['secure_url'];
      } else {
        throw Exception("Upload failed: ${resp.body}");
      }
    } catch (e) {
      print("❌ Cloudinary upload error: $e");
      return null;
    }
  }
}