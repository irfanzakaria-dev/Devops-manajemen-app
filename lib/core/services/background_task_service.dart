import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'online_sync_service.dart';
import 'notification_service.dart';

const String periodicSyncTaskKey = 'devops_periodic_sync_task';
const String oneOffSyncTaskKey = 'devops_oneoff_sync_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Eksekusi background task di latar belakang
      await OnlineSyncService.instance.syncLocalTasksToCloud();
      
      // Kirimkan notifikasi background task
      await NotificationService.instance.init();
      await NotificationService.instance.showNotification(
        id: 888,
        title: '🔄 Background Task Selesai',
        body: 'Sinkronisasi data DevOps ke server cloud berhasil dijalankan di latar belakang.',
      );
      return await Future.value(true);
    } catch (_) {
      return await Future.value(true);
    }
  });
}

class BackgroundTaskService {
  static final BackgroundTaskService instance = BackgroundTaskService._internal();
  BackgroundTaskService._internal();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().initialize(
          callbackDispatcher,
        );
        _isInitialized = true;
      } catch (e) {
        debugPrint('Workmanager initialization error: $e');
      }
    } else {
      _isInitialized = true;
    }
  }

  Future<void> registerPeriodicSync({required int intervalMinutes}) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().cancelByUniqueName(periodicSyncTaskKey);
        // WorkManager Android mewajibkan batas minimal 15 menit
        final frequency = Duration(minutes: intervalMinutes < 15 ? 15 : intervalMinutes);
        await Workmanager().registerPeriodicTask(
          periodicSyncTaskKey,
          periodicSyncTaskKey,
          frequency: frequency,
          constraints: Constraints(
            networkType: NetworkType.connected,
          ),
          existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        );
      } catch (e) {
        debugPrint('Workmanager registerPeriodicSync error: $e');
      }
    }
  }

  Future<void> cancelPeriodicSync() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().cancelByUniqueName(periodicSyncTaskKey);
      } catch (e) {
        debugPrint('Workmanager cancelPeriodicSync error: $e');
      }
    }
  }

  Future<void> triggerImmediateSync() async {
    // 1. Eksekusi sinkronisasi online langsung
    await OnlineSyncService.instance.syncLocalTasksToCloud();

    // 2. Jika di Android, picu juga Workmanager One-off task
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        await Workmanager().registerOneOffTask(
          '${oneOffSyncTaskKey}_${DateTime.now().millisecondsSinceEpoch}',
          oneOffSyncTaskKey,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } catch (e) {
        debugPrint('Workmanager triggerImmediateSync error: $e');
      }
    }

    // 3. Tampilkan notifikasi lokal
    await NotificationService.instance.showNotification(
      id: 888,
      title: '🔄 Background Task: Sinkronisasi Sukses',
      body: 'Data tugas SQLite telah disinkronkan ke server cloud online.',
    );
  }
}
