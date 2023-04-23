import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'get_prediction.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio File Picker',
      home: AudioFilePicker(),
    );
  }
}

class AudioFilePicker extends StatefulWidget {
  @override
  _AudioFilePickerState createState() => _AudioFilePickerState();
}

class _AudioFilePickerState extends State<AudioFilePicker> {
  Future<String> makeBase64(String path) async {
    try {
      File file = File(path);
      file.openRead();
      var contents = await file.readAsBytes();
      var base64File = base64.encode(contents);
      print(base64File);
      return base64File;
    } catch (e) {
      print(e.toString());

      return "";
    }
  }

  String _fileName = "";
  String filePath = "";
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null) {
      _fileName = result.files.single.name;

      File file = File(result.files.single.path!);
      print(file);
      setState(() {
        filePath = file.path as String;
      });
    }
  }

  Future<GetPrediction> askPrediction(String base64String) async {
    // setState(() {
    //   loading = true;
    // });
    // String base64String = base64Encode(img);
    // print(base64String);
    final response = await http.post(
      Uri.parse('https://3bb8-49-205-230-4.in.ngrok.io/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        // 'type': c,
        'audio': base64String,
      }),
    );
    print("hello res");
    if (response.statusCode == 200) {
      print("hello res");
      return GetPrediction.fromJson(jsonDecode(response.body));
    } else {
      print('Request failed with status: ${response.body}.');
      throw Exception('Failed to fetch');
    }
  }

  String res = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio File Picker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Select Audio File'),
            ),
            SizedBox(height: 16.0),
            _fileName != null
                ? Text(
                    'Selected Audio File: $_fileName',
                    style: TextStyle(fontSize: 16.0),
                  )
                : Container(),
            ElevatedButton(
              onPressed: () async {
                String s = await makeBase64(filePath);
                print(s);
                final GetPrediction out = await askPrediction(s);
                setState(() {
                  res = out.result;
                  print(res);
                });
                print(out.result);
              },
              child: Text('Predict'),
            ),
            SizedBox(height: 16.0),
            res != ""
                ? Text(
                    '$res',
                    style: TextStyle(fontSize: 16.0),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
