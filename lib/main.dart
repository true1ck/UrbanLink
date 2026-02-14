import 'package:flutter/material.dart';
import 'src/app.dart';
import 'src/core/service_locator.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services (storage, API client, etc.)
  await ServiceLocator().init();
  
  runApp(const App());
}
