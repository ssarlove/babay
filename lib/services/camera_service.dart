import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<List<CameraDescription>> initialize() async {
    try {
      _cameras = await availableCameras();
      
      // Prefer front camera for baby monitoring
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
      
      return _cameras;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      rethrow;
    }
  }

  Future<XFile?> captureFrame() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      return await _controller!.takePicture();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  void startStreaming(void Function(CameraImage image) onFrame) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    _controller!.startImageStream(onFrame);
  }

  void stopStreaming() {
    _controller?.stopImageStream();
  }

  Future<void> dispose() async {
    stopStreaming();
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  bool hasFrontCamera() {
    return _cameras.any((c) => c.lensDirection == CameraLensDirection.front);
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    final currentCamera = _controller?.description;
    final newCamera = _cameras.firstWhere(
      (c) => c != currentCamera,
      orElse: () => _cameras.first,
    );

    await _controller?.dispose();
    
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }
}