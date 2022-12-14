import 'dart:developer';

import 'package:video_uploader/video_uploader.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const primaryColor = Color(0xFFFA5B30);
const secondaryColor = Color(0xFFFFB39E);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String _imagePath;
  final _tokenTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  double _progressValue = 0;

  void setProgress(double value) async {
    setState(() {
      _progressValue = value;
    });
  }

  @override
  void dispose() {
    _tokenTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primaryColor: primaryColor,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: const Text('Uploader Example'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextButton(
                    child: Text('SET API KEY'),
                    onPressed: () => ApiVideoUploader.setApiKey('FOOBAR'),
                  ),
                  const SizedBox(
                    height: 52,
                  ),
                  TextField(
                    cursorColor: primaryColor,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: primaryColor, width: 2.0),
                      ),
                      hintText: 'My video token',
                    ),
                    controller: _tokenTextController,
                  ),
                  MaterialButton(
                    color: primaryColor,
                    child: const Text(
                      "Pick Video from Gallery",
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      var source = ImageSource.gallery;
                      XFile? image = await _picker.pickVideo(source: source);
                      if (image != null) {
                        setState(() {
                          try {
                            _imagePath = image.path;
                          } catch (e) {
                            log("Failed to get video: $e");
                          }
                        });
                      }
                    },
                  ),
                  MaterialButton(
                    color: primaryColor,
                    child: const Text(
                      "Upload video",
                      style: TextStyle(
                          color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      try {
                        var video =
                            await ApiVideoUploader.uploadWithUploadToken(
                                _tokenTextController.text, _imagePath,
                                (bytesSent, totalByte) {
                          log("Progress : ${bytesSent / totalByte}");
                          setProgress(bytesSent / totalByte);
                        });
                        log("Video : $video");
                        log("Title : ${video.title}");
                      } catch (e) {
                        log("Failed to upload video: $e");
                      }
                    },
                  ),
                  LinearProgressIndicator(
                    color: primaryColor,
                    backgroundColor: secondaryColor,
                    value: _progressValue,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
