import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/online_sync_service.dart';
import 'core/services/background_task_service.dart';
import 'features/auth/models/user_session.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/home/presentation/role_dashboard_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  await SettingsService.instance.init();
  await OnlineSyncService.instance.init();
  await BackgroundTaskService.instance.init();
  
  if (SettingsService.instance.autoSyncEnabled) {
    await BackgroundTaskService.instance.registerPeriodicSync(
      intervalMinutes: SettingsService.instance.syncIntervalMinutes,
    );
  }

  await UserSession.instance.init();
  runApp(const DevOpsManagementApp());
}

class DevOpsManagementApp extends StatelessWidget {
  const DevOpsManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SettingsService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'DevOps Management',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: SettingsService.instance.themeMode,
          home: UserSession.instance.isAuthenticated
              ? const RoleDashboardPreview()
              : const WelcomeScreen(),
        );
      },
    );
  }
}
