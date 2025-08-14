import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'doanvrjez';

  static final CloudinaryService instance = CloudinaryService();

  Future<String?> uploadImage(File imageFile) async {
    return _upload(imageFile, 'flutter_upload');
  }

  Future<String?> postImage(File imageFile) async {
    return _upload(imageFile, 'post_upload');
  }

  Future<String?> _upload(File imageFile, String preset) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = preset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final decodedData = jsonDecode(responseBody);
      log(jsonEncode(decodedData));
      return decodedData['secure_url'];
    } else {
      log('upload failed with status: ${response.statusCode}');
      return null;
    }
  }
}
