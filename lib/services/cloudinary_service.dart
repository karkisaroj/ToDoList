import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = 'doanvrjez';
  final String uploadPreset = 'flutter_upload';
  static final CloudinaryService instance = CloudinaryService();
  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/doanvrjez/image/upload',
    );
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
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
