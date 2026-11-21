import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/utils/lifecycle_observer.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/pos_viewmodel.dart';
import 'viewmodels/inventory_viewmodel.dart';
import 'views/auth/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('pawon_offline_box');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PosViewModel()),
        ChangeNotifierProvider(create: (_) => InventoryViewModel()),
      ],
      child: const PawonCengekApp(),
    ),
  );
}

class PawonCengekApp extends StatefulWidget {
  const PawonCengekApp({super.key});

  @override
  State<PawonCengekApp> createState() => _PawonCengekAppState();
}

class _PawonCengekAppState extends State<PawonCengekApp> {
  final AppLifecycleHandler _lifecycleHandler = AppLifecycleHandler();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_lifecycleHandler);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleHandler);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawon Cengek POS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginView(),
    );
  }
}
