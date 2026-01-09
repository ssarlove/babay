import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../services/emotion_detector.dart';
import '../services/suggestion_engine.dart';
import '../services/storage_service.dart';
import '../components/camera_preview.dart';
import '../components/emotion_display.dart';
import '../components/suggestion_card.dart';
import '../utils/permissions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final EmotionDetector _emotionDetector = EmotionDetector();
  final SuggestionEngine _suggestionEngine = SuggestionEngine();
  
  bool _isAnalyzing = false;
  Map<String, dynamic>? _currentResult;
  AnimationController? _animationController;
  Animation<double>? _scanAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _initializeCamera();
    _emotionDetector.loadModel();
  }

  Future<void> _initializeCamera() async {
    final hasPermission = await Permissions.checkCameraPermission();
    if (hasPermission) {
      await _cameraService.initialize();
      setState(() {});
    } else {
      await Permissions.requestCameraPermission();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required to scan baby\'s emotions')),
        );
      }
    }
  }

  Future<void> _analyzeEmotion() async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
      _currentResult = null;
    });

    try {
      final XFile? imageFile = await _cameraService.captureFrame();
      if (imageFile == null) {
        _showError('Failed to capture image');
        return;
      }

      // Read and decode image
      final bytes = await imageFile.readAsBytes();
      final image = decodeImage(bytes);
      
      if (image == null) {
        _showError('Failed to process image');
        return;
      }

      // Analyze emotion
      final result = await _emotionDetector.analyzeImage(image);
      
      if (result == null || !result['hasFace']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No face detected. Please align baby\'s face in the frame.')),
          );
        }
        setState(() {
          _isAnalyzing = false;
        });
        return;
      }

      // Get suggestions
      final suggestions = _suggestionEngine.getSuggestions(
        result['emotion'],
        timestamp: DateTime.now(),
      );

      // Save to history
      final storageService = Provider.of<StorageService>(context, listen: false);
      final emotionResult = EmotionResult(
        dominantEmotion: result['emotion'],
        probabilities: Map<String, double>.from(result['probabilities'] ?? {}),
        suggestions: suggestions.map((s) => s['text'] as String).toList(),
      );
      await storageService.saveEmotionResult(emotionResult);

      if (mounted) {
        setState(() {
          _currentResult = {
            ...result,
            'suggestions': suggestions,
            'confidence': result['confidence'] * 100,
          };
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      debugPrint('Analysis error: $e');
      _showError('An error occurred during analysis');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageService = Provider.of<StorageService>(context);
    final useNightMode = storageService.useNightMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baby Care'),
        centerTitle: true,
        actions: [
          if (useNightMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: const Text('Night Mode'),
                backgroundColor: Colors.red.withOpacity(0.2),
                deleteIcon: const Icon(Icons.nights_stay, color: Colors.red),
                onDeleted: () {},
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                // Camera preview
                CameraPreviewWidget(
                  cameraService: _cameraService,
                  isInitialized: _cameraService.isInitialized,
                ),
                
                // Scanning overlay
                if (_isAnalyzing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Analyzing...',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // Face guide overlay
                if (!_isAnalyzing && _currentResult == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: FaceGuidePainter(scanAnimation: _scanAnimation),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Analysis button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeEmotion,
              icon: _isAnalyzing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics),
              label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Baby\'s State'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          
          // Results section
          if (_currentResult != null)
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EmotionDisplay(
                      emotion: _currentResult!['emotion'],
                      confidence: _currentResult!['confidence'],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Suggestions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...(_currentResult!['suggestions'] as List<dynamic>).map(
                      (suggestion) => SuggestionCard(
                        text: suggestion['text'] as String,
                        category: suggestion['category'] as String,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            const Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  'Point camera at your baby and tap "Analyze"',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _emotionDetector.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}

class FaceGuidePainter extends CustomPainter {
  final Animation<double>? scanAnimation;

  FaceGuidePainter({this.scanAnimation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final circleRadius = size.width * 0.35;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw circle guide
    canvas.drawCircle(center, circleRadius, paint);

    // Draw scanning line
    final lineY = center.dy + (scanAnimation?.value ?? 0) * circleRadius * 1.5 - circleRadius * 0.75;
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawLine(
      Offset(center.dx - circleRadius * 0.7, lineY),
      Offset(center.dx + circleRadius * 0.7, lineY),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant FaceGuidePainter oldDelegate) {
    return oldDelegate.scanAnimation != scanAnimation;
  }
}