import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import '../../models/obat_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final Map<String, int> _mapHari = {
    'Sen': 1,
    'Sel': 2,
    'Rab': 3,
    'Kam': 4,
    'Jum': 5,
    'Sab': 6,
    'Min': 7,
  };

  static Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotifTap,
    );

    const channel = AndroidNotificationChannel(
      'obat_channel',
      'Pengingat Obat',
      description: 'Notifikasi jadwal minum obat',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static void _onNotifTap(NotificationResponse response) {
    final obatId = response.payload;
    if (obatId == null) return;

    if (response.actionId == 'sudah_minum') {
      updateStatusObat(obatId, MedStatus.sudah);
    } else if (response.actionId == 'lewati') {
      updateStatusObat(obatId, MedStatus.terlewat);
    } else {
      final obat = daftarObat.where((o) => o.id == obatId);
      if (obat.isNotEmpty) {
        catatPengingatMinum(obat.first);
      }
    }
  }

  static Future<void> jadwalkanNotifObat({
    required String obatId,
    required String namaObat,
    required String dosis,
    required String jamMenit,
    required Set<String> hariAktif,
  }) async {
    final parts = jamMenit.split(':');
    if (parts.length != 2) return;
    final jam = int.tryParse(parts[0]) ?? 0;
    final menit = int.tryParse(parts[1]) ?? 0;

    for (final hari in hariAktif) {
      final weekday = _mapHari[hari];
      if (weekday == null) continue;

      final notifId = _buatNotifId(obatId, hari);

      await _plugin.zonedSchedule(
        notifId,
        'Waktunya minum obat 💊',
        '$namaObat ($dosis) - jangan lupa diminum ya!',
        _nextInstanceOfWeekday(weekday, jam, menit),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'obat_channel',
            'Pengingat Obat',
            channelDescription: 'Notifikasi jadwal minum obat',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            actions: [
              AndroidNotificationAction('sudah_minum', 'Sudah Minum'),
              AndroidNotificationAction('lewati', 'Lewati'),
            ],
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: obatId,
      );
    }
  }

  static Future<void> batalkanNotifObat(
      String obatId, Set<String> hariAktif) async {
    for (final hari in hariAktif) {
      final notifId = _buatNotifId(obatId, hari);
      await _plugin.cancel(notifId);
    }
  }

  static Future<void> updateNotifObat({
    required String obatId,
    required String namaObat,
    required String dosis,
    required String jamMenit,
    required Set<String> hariLama,
    required Set<String> hariBaru,
  }) async {
    await batalkanNotifObat(obatId, hariLama);
    await jadwalkanNotifObat(
      obatId: obatId,
      namaObat: namaObat,
      dosis: dosis,
      jamMenit: jamMenit,
      hariAktif: hariBaru,
    );
  }

  static Future<void> notifStokMenipis({
    required String obatId,
    required String namaObat,
    required int hariLagi,
  }) async {
    await _plugin.show(
      _buatNotifId(obatId, 'stok'),
      'Stok obat menipis ⚠️',
      '$namaObat tersisa untuk $hariLagi hari lagi. Segera isi ulang!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'obat_channel',
          'Pengingat Obat',
          channelDescription: 'Notifikasi jadwal minum obat',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: obatId,
    );
  }

  static int _buatNotifId(String obatId, String suffix) =>
      '$obatId-$suffix'.hashCode;

  static tz.TZDateTime _nextInstanceOfWeekday(
      int weekday, int jam, int menit) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, jam, menit);

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}