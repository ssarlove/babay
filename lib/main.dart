import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for non-web platforms
  if (!kIsWeb) {
    await Hive.initFlutter();
    await Hive.openBox('baby_care_preferences');
    await Hive.openBox('mood_history');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StorageService()),
      ],
      child: const BabyCareApp(),
    ),
  );
}
