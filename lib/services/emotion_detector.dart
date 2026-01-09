import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class EmotionDetector {
  Interpreter? _interpreter;
  final List<String> _labels = ['angry', 'disgust', 'fear', 'happy', 'sad', 'surprise', 'neutral'];
  final FaceDetector _faceDetector;
  
  // Baby-specific emotion mapping
  final Map<String, String> _babyEmotionMapping = {
    'happy': 'happy',
    'sad': 'crying',
    'surprise': 'neutral',
    'neutral': 'neutral',
    'angry': 'crying',
    'fear': 'crying',
    'disgust': 'crying',
  };

  EmotionDetector() : _faceDetector = FaceDetector(options: FaceDetectorOptions(
    enableContours: false,
    enableLandmarks: false,
    performanceMode: FaceDetectorPerformanceMode.fast,
  ));

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/emotion_model.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      debugPrint('Emotion model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
      // Use a placeholder for development
      _interpreter = null;
    }
  }

  Future<Map<String, dynamic>?> analyzeImage(img.Image image) async {
    if (_interpreter == null) {
      debugPrint('Model not loaded, skipping analysis');
      return null;
    }

    try {
      // Detect faces
      final inputImage = InputImage.fromFileImage(
        MemoryImage(image.toBytes()),
      );
      
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        return {'emotion': 'neutral', 'confidence': 0.0, 'probabilities': {}, 'hasFace': false};
      }

      // Use the largest face
      final face = faces.reduce((a, b) => a.boundingBox.width * a.boundingBox.height > 
          b.boundingBox.width * b.boundingBox.height ? a : b);
      
      // Crop and preprocess face
      final faceImage = _cropFace(image, face.boundingBox);
      final input = _preprocess(faceImage);

      // Run inference
      final output = List.filled(7, 0.0).reshape([1, 7]);
      _interpreter!.run(input, output);

      // Process results
      final probabilities = <String, double>{};
      for (int i = 0; i < _labels.length; i++) {
        probabilities[_labels[i]] = output[0][i];
      }

      // Find dominant emotion
      final sortedEntries = probabilities.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final dominantLabel = sortedEntries[0].key;
      final confidence = sortedEntries[0].value;

      // Map to baby-specific emotions
      final babyEmotion = _babyEmotionMapping[dominantLabel] ?? 'neutral';

      return {
        'emotion': babyEmotion,
        'confidence': confidence,
        'probabilities': probabilities,
        'hasFace': true,
      };
    } catch (e) {
      debugPrint('Analysis error: $e');
      return null;
    }
  }

  img.Image _cropFace(img.Image image, Rect boundingBox) {
    final x = boundingBox.left.round();
    final y = boundingBox.top.round();
    final width = boundingBox.width.round();
    final height = boundingBox.height.round();

    // Ensure bounds are within image
    final cropX = x.clamp(0, image.width - 1);
    final cropY = y.clamp(0, image.height - 1);
    final cropWidth = width.clamp(1, image.width - cropX);
    final cropHeight = height.clamp(1, image.height - cropY);

    return img.copyCrop(image, cropX, cropY, cropWidth, cropHeight);
  }

  List<List<List<List<double>>>> _preprocess(img.Image image) {
    // Resize to 48x48 (standard for emotion models)
    final resized = img.copyResize(image, width: 48, height: 48);
    
    final input = List.generate(1, (_) => 
      List.generate(48, (_) => 
        List.generate(48, (_) => 
          List.filled(3, 0.0)
        )
      )
    );

    for (int y = 0; y < 48; y++) {
      for (int x = 0; x < 48; x++) {
        final pixel = resized.getPixel(x, y);
        input[0][y][x][0] = ((pixel >> 16) & 0xFF) / 255.0;
        input[0][y][x][1] = ((pixel >> 8) & 0xFF) / 255.0;
        input[0][y][x][2] = (pixel & 0xFF) / 255.0;
      }
    }

    return input;
  }

  void dispose() {
    _faceDetector.close();
    _interpreter?.close();
  }
}