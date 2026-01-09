import 'package:flutter/material.dart';
import '../services/camera_service.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraService cameraService;
  final bool isInitialized;

  const CameraPreviewWidget({
    super.key,
    required this.cameraService,
    required this.isInitialized,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing camera...'),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CameraPreview(
        cameraService.controller!,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Add any overlays on top of camera
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}