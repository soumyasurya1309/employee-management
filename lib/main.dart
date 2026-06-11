import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_edit_employee_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/employee_detail_screen.dart';
import 'screens/employee_list_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: const EmployeeManagementApp(),
    ),
  );
}

class EmployeeManagementApp extends StatelessWidget {
  const EmployeeManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'EmpManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      scaffoldMessengerKey: NotificationService.messengerKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final routes = {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/employees': (context) => const EmployeeListScreen(),
          '/employees/add': (context) => const AddEditEmployeeScreen(),
          '/employees/edit': (context) => const AddEditEmployeeScreen(),
          '/employees/detail': (context) => const EmployeeDetailScreen(),
        };
        final builder = routes[settings.name];
        if (builder == null) return null;
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}