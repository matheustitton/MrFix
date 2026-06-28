import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'data/datasources/remote_data_source.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/service_request_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/providers/notification_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MisterFixApp());
}

class MisterFixApp extends StatelessWidget {
  const MisterFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = RemoteDataSource();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(dataSource)),
        ChangeNotifierProvider(create: (_) => ServiceRequestProvider(dataSource)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(RemoteDataSource()),
),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, theme, __) => MaterialApp(
          title: 'MisterFix',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: theme.mode,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}