import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dropbox {
  static Future<void> upload() async {
    var filePath = 'path_to_your_file';
    var file = File(filePath);
    var fileContent = await file.readAsBytes();

    var url = Uri.parse('https://content.dropboxapi.com/2/files/upload');

    var headers = {
      'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
      'Dropbox-API-Arg': json.encode({
        'path': '/your_dropbox_folder/${file.path.split('/').last}',
        'mode': 'add',
        'autorename': true,
        'mute': false,
        'strict_conflict': false,
      }),
      'Content-Type': 'application/octet-stream',
    };

    var response = await http.post(url, headers: headers, body: fileContent);

    if (response.statusCode == 200) {
      print('File uploaded successfully');
    } else {
      print('Failed to upload file: ${response.statusCode}');
    }
  }
}
