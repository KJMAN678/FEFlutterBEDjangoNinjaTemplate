import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

const String apiUrl = String.fromEnvironment('API_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(camera: firstCamera),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

// TODO: アプリのライフサイクル変更時にカメラコントローラの状態を処理することを検討する
class TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  String _message = 'Calling API...';

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    // アプリのライフサイクルを監視
    WidgetsBinding.instance.addObserver(this);

    _callApi();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // アプリがフォアグラウンドに戻ったときに最新の値を取得
    if (state == AppLifecycleState.resumed) {
      _callApi();
    }
  }

  Future<void> _callApi() async {
    try {
      final res = await http.get(Uri.parse("$apiUrl/api/count_saved_images/"));
      if (mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          _message = data["response"];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _message = 'Error: $e';
        });
      }
    }
  }

  Future<void> uploadImage(File imageFile) async {
    final image_upload_url = Uri.parse("$apiUrl/api/upload_image/");
    final request = http.MultipartRequest("POST", image_upload_url);
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      imageFile.path,
      // contentType: MediaType('image','jpeg'), // 必要なら
    );
    request.files.add(multipartFile);

    // リクエスト送信
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      print('Upload success: ${response.body}');
    } else {
      print('Upload failed (${response.statusCode}): ${response.body}');
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$_message')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          final image;
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            _controller.pausePreview();

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            uploadImage(File(image.path));

            if (!context.mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image.path,
                ),
              ),
            );
            // 画面から戻ってきたときに最新の値を取得
            _callApi();
            await _controller.resumePreview();
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('test image')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
