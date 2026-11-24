import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/auth/models/user_session.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/home/presentation/role_dashboard_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await UserSession.instance.init();
  runApp(const DevOpsManagementApp());
}

class DevOpsManagementApp extends StatelessWidget {
  const DevOpsManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevOps Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: UserSession.instance.isAuthenticated
          ? const RoleDashboardPreview()
          : const WelcomeScreen(),
    );
  }
}
