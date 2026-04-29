import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/network/api_client.dart';
import 'package:petsafe_movil_app/core/notifications/fcm_service.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/adoption/presentation/adoption_page.dart';
import 'package:petsafe_movil_app/features/appointments/presentation/appointments_page.dart';
import 'package:petsafe_movil_app/features/dashboard/presentation/dashboard_page.dart';
import 'package:petsafe_movil_app/features/history/presentation/history_page.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_repository_factory.dart';
import 'package:petsafe_movil_app/features/notifications/presentation/notifications_page.dart';
import 'package:petsafe_movil_app/features/pets/presentation/pets_page.dart';
import 'package:dio/dio.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  int _unreadCount = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardPage(),
    PetsPage(),
    AppointmentsPage(),
    HistoryPage(),
    AdoptionPage(),
    NotificationsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initFcm();
    _loadUnreadCount();
  }

  Future<void> _initFcm() async {
    try {
      final token = await FcmService.instance.initialize(
        onForegroundMessage: (message) {
          final title = FcmService.notificationTitle(message);
          final body = FcmService.notificationBody(message);
          if (mounted && (title != null || body != null)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${title ?? ''}: ${body ?? ''}'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Ver',
                  onPressed: () => setState(() => _currentIndex = 5),
                ),
              ),
            );
            _loadUnreadCount();
          }
        },
      );

      if (token != null && token.isNotEmpty) {
        await _registerFcmToken(token);
      }

      FcmService.instance.onTokenRefresh((newToken) async {
        await _registerFcmToken(newToken);
      });
    } catch (_) {}
  }

  Future<void> _registerFcmToken(String token) async {
    try {
      final sessionStorage = FlutterSecureSessionStorage(const FlutterSecureStorage());
      final apiClient = ApiClient();
      final accessToken = await sessionStorage.readAccessToken();
      final headers = <String, dynamic>{};
      if (accessToken != null && accessToken.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${accessToken.trim()}';
      }
      await apiClient.dio.post<dynamic>(
        '/notifications/device-token',
        data: {'fcmToken': token, 'platform': 'android'},
        options: Options(headers: headers),
      );
    } catch (_) {}
  }

  Future<void> _loadUnreadCount() async {
    try {
      final repo = NotificationRepositoryFactory.create();
      final count = await repo.loadUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x120F172A),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                if (index == 5) _loadUnreadCount();
              },
              backgroundColor: Colors.transparent,
              indicatorColor: AppColors.activeSoft,
              elevation: 0,
              height: 72,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Inicio',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.pets_outlined),
                  selectedIcon: Icon(Icons.pets_rounded),
                  label: 'Mascotas',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Citas',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.description_outlined),
                  selectedIcon: Icon(Icons.description_rounded),
                  label: 'Historial',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Adopcion',
                ),
                NavigationDestination(
                  icon: _unreadCount > 0
                      ? Badge(
                          label: Text('$_unreadCount'),
                          child: const Icon(Icons.notifications_outlined),
                        )
                      : const Icon(Icons.notifications_outlined),
                  selectedIcon: _unreadCount > 0
                      ? Badge(
                          label: Text('$_unreadCount'),
                          child: const Icon(Icons.notifications_rounded),
                        )
                      : const Icon(Icons.notifications_rounded),
                  label: 'Avisos',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
