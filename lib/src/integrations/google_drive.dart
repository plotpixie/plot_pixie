import 'dart:io';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class GoogleDrive {

  static Future<void> upload() async {
    var clientId = ClientId('YOUR_CLIENT_ID', 'YOUR_CLIENT_SECRET');

    var scopes = [drive.DriveApi.driveScope];

    var client = await clientViaUserConsent(clientId, scopes, prompt);

    var api = drive.DriveApi(client);
    var fileToUpload = File('path_to_your_file');
    var media = drive.Media(fileToUpload.openRead(), fileToUpload.lengthSync());

    var driveFile = drive.File();
    driveFile.name = 'your_file_name';

    var result = await api.files.create(driveFile, uploadMedia: media);

    print('Uploaded file ${result.id}');
  }

  static void prompt(String url) {
    print('Please go to the following URL and grant access:');
    print('  => $url');
    print('');
  }
}
