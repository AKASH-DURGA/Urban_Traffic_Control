// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'get_prediction.dart';
// import 'package:http/http.dart' as http;
// import 'get_results.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Audio File Picker',
//       home: AudioFilePicker(),
//     );
//   }
// }

// class AudioFilePicker extends StatefulWidget {
//   @override
//   _AudioFilePickerState createState() => _AudioFilePickerState();
// }

// class _AudioFilePickerState extends State<AudioFilePicker> {
//   final CollectionReference _students =
//       FirebaseFirestore.instance.collection('results');

//   String _fileNameController = "";
//   String _resultController = "";

//   Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
//     final String fileName = _fileNameController;
//     final String _result = _resultController;
//     _students.add({
//       "File Name": fileName,
//       "Result": _result,
//     });

//     _fileNameController = '';
//     _resultController = '';
//   }

//   Future<String> makeBase64(String path) async {
//     try {
//       File file = File(path);
//       file.openRead();
//       var contents = await file.readAsBytes();
//       var base64File = base64.encode(contents);
//       print(base64File);
//       return base64File;
//     } catch (e) {
//       print(e.toString());

//       return "";
//     }
//   }

//   String _fileName = "";
//   String filePath = "";
//   Future<void> _pickFile() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//     );
//     if (result != null) {
//       _fileName = result.files.single.name;

//       File file = File(result.files.single.path!);
//       print(file);
//       setState(() {
//         filePath = file.path as String;
//       });
//     }
//   }

//   void _navigateToNextScreen(BuildContext context) {
//     Navigator.of(context)
//         .push(MaterialPageRoute(builder: (context) => Results()));
//   }

//   Future<GetPrediction> askPrediction(String base64String) async {
//     // setState(() {
//     //   loading = true;
//     // });
//     // String base64String = base64Encode(img);
//     // print(base64String);
//     final response = await http.post(
//       Uri.parse('https://a6a0-49-205-229-186.in.ngrok.io/predict'),
//       headers: <String, String>{
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(<String, dynamic>{
//         // 'type': c,
//         'audio': base64String,
//       }),
//     );
//     print("hello res");
//     if (response.statusCode == 200) {
//       print("hello res");
//       return GetPrediction.fromJson(jsonDecode(response.body));
//     } else {
//       print('Request failed with status: ${response.body}.');
//       throw Exception('Failed to fetch');
//     }
//   }

//   String res = "";
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Urban Traffic Control'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//                 onPressed: () => {_navigateToNextScreen(context)},
//                 child: const Text('Saved Results')),
//             ElevatedButton(
//               onPressed: _pickFile,
//               child: Text('Select Audio File'),
//             ),
//             SizedBox(height: 16.0),
//             _fileName != null
//                 ? Text(
//                     'Selected Audio File: $_fileName',
//                     style: TextStyle(fontSize: 16.0),
//                   )
//                 : Container(),
//             ElevatedButton(
//               onPressed: () async {
//                 String s = await makeBase64(filePath);
//                 print(s);
//                 final GetPrediction out = await askPrediction(s);
//                 setState(() {
//                   res = out.result;
//                   print(res);
//                 });
//                 print(out.result);
//               },
//               child: Text('Predict'),
//             ),
//             SizedBox(height: 16.0),
//             res != ""
//                 ? Text(
//                     '$res',
//                     style: TextStyle(fontSize: 16.0),
//                   )
//                 : Container(),
//             res != ""
//                 ? ElevatedButton(
//                     onPressed: () => {
//                           _fileNameController = _fileName,
//                           _resultController = res,
//                           _create()
//                         },
//                     child: Text('Save Result'))
//                 : Container()
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'get_prediction.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'get_results.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Classifier',
      home: AudioFilePicker(),
    );
  }
}

class AudioFilePicker extends StatefulWidget {
  @override
  _AudioFilePickerState createState() => _AudioFilePickerState();
}

class _AudioFilePickerState extends State<AudioFilePicker> {
  final CollectionReference Sounds =
      FirebaseFirestore.instance.collection('results');

  String _fileNameController = "";
  String _resultController = "";

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    final String fileName = _fileNameController;
    final String _result = _resultController;
    Sounds.add({
      "File Name": fileName,
      "Result": _result,
    });

    _fileNameController = '';
    _resultController = '';
  }

  String res1 = "";
  String res2 = "";
  String res3 = "";

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

  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  void playAudio() async {
    File file = File(filePath);
    await audioPlayer.play(filePath);
    setState(() {
      isPlaying = true;
    });
  }

  void pauseAudio() async {
    await audioPlayer.pause();
    setState(() {
      isPlaying = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.stop();
  }

  Future<GetPrediction> askPrediction(String base64String) async {
    final response = await http.post(
      Uri.parse('https://55d4-49-205-229-186.in.ngrok.io/predict'),
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

  void _navigateToNextScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Results()));
  }

  String res = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sound Classifier',
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => {_navigateToNextScreen(context)},
                child: const Text('Saved Results')),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(
                'Select Audio File',
              ),
            ),
            SizedBox(height: 16.0),
            _fileName != null
                ? Text(
                    'Selected Audio File: $_fileName',
                  )
                : Container(),
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: isPlaying ? pauseAudio : playAudio,
                    child: Text(isPlaying ? 'Pause' : 'Play'),
                  ),
                ],
              ),
            ),
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
                  )
                : Container(),
            res != ""
                ? ElevatedButton(
                    onPressed: () => {
                          _fileNameController = _fileName,
                          _resultController = res,
                          _create()
                        },
                    child: Text('Save Result'))
                : Container()
          ],
        ),
      ),
    );
  }
}
