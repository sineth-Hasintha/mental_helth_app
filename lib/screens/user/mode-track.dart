import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  CameraController? _controller;
  bool _isBusy = false;
  bool _canDetect = true;
  String _currentMood = "Scanning...";
  final List<Map<String, String>> _history = [];
  CameraDescription? _cameraDescription;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  String _getEmoji(String mood) {
    switch (mood) {
      case "Happy": return "😊";
      case "Sad": return "😔";
      case "Angry": return "😠";
      case "Anxious": return "😰";
      case "Neutral": return "😐";
      default: return "🔍";
    }
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraDescription = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      _cameraDescription!,
      ResolutionPreset.low,
      enableAudio: false,
    );

    try {
      await _controller?.initialize();
      _controller?.startImageStream((image) {
        if (_isBusy || !_canDetect) return;
        _processImage(image);
      });
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _processImage(CameraImage image) async {
    _isBusy = true;
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty && _canDetect) {
        final face = faces.first;
        double smile = face.smilingProbability ?? 0.0;
        double leftEye = face.leftEyeOpenProbability ?? 1.0;
        double rightEye = face.rightEyeOpenProbability ?? 1.0;

        String mood = "Neutral";
        if (smile > 0.5) {
          mood = "Happy";
        } else if (smile < 0.1 && (leftEye < 0.5 || rightEye < 0.5)) {
          mood = "Sad";
        } else if (smile < 0.05 && (leftEye > 0.9 && rightEye > 0.9)) {
          mood = "Angry";
        } else if (leftEye < 0.4 && rightEye < 0.4) {
          mood = "Anxious";
        } else {
          mood = "Neutral";
        }

        _canDetect = false;
        _updateMood(mood);
        await _controller?.stopImageStream();
      }
    } catch (e) {
      debugPrint("Detection Error: $e");
    } finally {
      _isBusy = false;
    }
  }

  void _updateMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_mood', mood);

    if (mounted) {
      setState(() {
        _currentMood = mood;
        _history.insert(0, {
          "mood": mood,
          "date": DateFormat('hh:mm a | dd MMM').format(DateTime.now()),
        });
      });
    }
  }

  void _resetDetection() async {
    setState(() {
      _canDetect = true;
      _currentMood = "Scanning...";
    });

    await _controller?.startImageStream((image) {
      if (_isBusy || !_canDetect) return;
      _processImage(image);
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      final imageRotation = InputImageRotationValue.fromRawValue(
        _cameraDescription!.sensorOrientation,
      ) ?? InputImageRotation.rotation90deg;
      final inputImageMetadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      return InputImage.fromBytes(bytes: bytes, metadata: inputImageMetadata);
    } catch (e) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    // Screen dimensions ලබා ගැනීම (සම්පූර්ණ නමින්)
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // පසුබිම් රවුම් (Responsive Positions)
          _circle(screenWidth * 0.6, const Color(0xFF06BA2C), top: -screenHeight * 0.05, right: -screenWidth * 0.2),
          _circle(screenWidth * 0.7, const Color(0xFF02BC02), bottom: -screenHeight * 0.1, left: -screenWidth * 0.2),

          SafeArea(
            child: Column(
              children: [
                // Back Button Area
                Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, size: screenWidth * 0.06),
                        onPressed: () => Navigator.pop(context)
                    )
                ),

                // Main Display Container
                Container(
                  width: screenWidth * 0.85,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                  decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(screenWidth * 0.08)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "Today's Mood",
                          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Emoji / Camera Display
                      ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.5),
                        child: Container(
                          width: screenWidth * 0.35,
                          height: screenWidth * 0.35,
                          color: Colors.white,
                          child: _canDetect
                              ? (_controller != null && _controller!.value.isInitialized
                              ? CameraPreview(_controller!)
                              : const Center(child: CircularProgressIndicator()))
                              : Center(
                              child: Text(
                                  _getEmoji(_currentMood),
                                  style: TextStyle(fontSize: screenWidth * 0.18)
                              )
                          ),
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.025),
                      Text(
                          "You are feeling: $_currentMood",
                          style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold)
                      ),

                      if (!_canDetect) ...[
                        SizedBox(height: screenHeight * 0.025),
                        ElevatedButton(
                          onPressed: _resetDetection,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.015),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.05))
                          ),
                          child: Text("Scan Again", style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.04)),
                        ),
                      ]
                    ],
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),
                Text(
                    "Mood History",
                    style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)
                ),

                // History List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06, vertical: screenHeight * 0.02),
                    itemCount: _history.length,
                    itemBuilder: (context, index) => Card(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                      color: const Color(0xFF399015),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.03)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.005),
                        leading: Text(_getEmoji(_history[index]['mood']!), style: TextStyle(fontSize: screenWidth * 0.07)),
                        title: Text(
                            _history[index]['date']!,
                            style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.035)
                        ),
                        trailing: Text(
                            _history[index]['mood']!,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04)
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color, {double? top, double? right, double? bottom, double? left}) {
    return Positioned(
        top: top, right: right, bottom: bottom, left: left,
        child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color))
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}