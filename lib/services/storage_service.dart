import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StorageService {
  final String _cloudName = 'dgrnexqep';
  final String _uploadPreset = 'ppjhgbe7';

  Future<String> uploadProfileImage({
    required String uid,
    required Uint8List bytes,
  }) async {
    return _uploadToCloudinary(bytes, 'profile_images/$uid', resourceType: 'image');
  }

  Future<String> uploadResume({
    required String userId,
    required String jobId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = fileName.contains('.') ? fileName.split('.').last : 'pdf';
    return _uploadToCloudinary(
      bytes, 
      'resumes/$userId/${jobId}_$timestamp.$ext', 
      resourceType: 'image', 
      filename: fileName,
    );
  }

  Future<String> _uploadToCloudinary(Uint8List bytes, String publicId, {String resourceType = 'auto', String? filename}) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload');
    
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = publicId
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename ?? publicId.split('/').last,
        ),
      );

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = json.decode(responseData);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonResponse['secure_url'] as String;
    } else {
      throw Exception('Failed to upload: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
    }
  }
}
