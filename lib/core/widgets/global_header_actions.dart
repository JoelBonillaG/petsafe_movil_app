import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:petsafe_movil_app/app/router/app_routes.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/widgets/network_image_tiles.dart';
import 'package:petsafe_movil_app/core/storage/secure_session_storage.dart';
import 'package:petsafe_movil_app/features/auth/data/auth_repository_factory.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_models.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_repository_factory.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_repository.dart';

enum _GlobalHeaderMenuAction { profile, signOut }

List<Widget> buildGlobalHeaderActions(BuildContext context) {
  return <Widget>[
    const _NotificationBell(),
    _UserAvatarButton(context: context),
    const SizedBox(width: 8),
  ];
}

// ── Notification bell ────────────────────────────────────────────────────────

class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final repo = NotificationRepositoryFactory.create();
      final count = await repo.loadUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await _showNotificationsSheet(context);
        _loadCount();
      },
      tooltip: _unreadCount > 0 ? 'Notificaciones ($_unreadCount)' : 'Notificaciones',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded),
          if (_unreadCount > 0)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 16,
                height: 16,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _unreadCount > 9 ? '9+' : '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── User avatar button ───────────────────────────────────────────────────────

class _UserAvatarButton extends StatefulWidget {
  const _UserAvatarButton({required this.context});
  final BuildContext context;

  @override
  State<_UserAvatarButton> createState() => _UserAvatarButtonState();
}

class _UserAvatarButtonState extends State<_UserAvatarButton> {
  String _fullName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final storage = FlutterSecureSessionStorage(const FlutterSecureStorage());
      final snapshot = await storage.readUserSnapshot();
      if (snapshot == null || snapshot.isEmpty) return;
      final map = jsonDecode(snapshot);
      if (map is Map) {
        final first = map['firstName']?.toString().trim() ?? '';
        final last = map['lastName']?.toString().trim() ?? '';
        final name = '$first $last'.trim();
        if (mounted && name.isNotEmpty) setState(() => _fullName = name);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_GlobalHeaderMenuAction>(
      tooltip: 'Opciones de perfil',
      onSelected: (action) => _handleGlobalHeaderAction(context, action),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _GlobalHeaderMenuAction.profile,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_rounded),
            title: Text('Configurar perfil'),
          ),
        ),
        PopupMenuItem(
          value: _GlobalHeaderMenuAction.signOut,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout_rounded, color: AppColors.warning),
            title: Text('Cerrar sesion'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: UserInitialsAvatar(
          fullName: _fullName,
          size: 36,
          showShadow: false,
        ),
      ),
    );
  }
}

// ── Notifications sheet ──────────────────────────────────────────────────────

Future<void> _showNotificationsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => const _NotificationsSheet(),
  );
}

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late final NotificationRepository _repo;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;

  @override
  void initState() {
    super.initState();
    _repo = NotificationRepositoryFactory.create();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final items = await _repo.loadMine();
      if (mounted) setState(() => _notifications = items);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    try {
      await _repo.markRead(n.id);
      if (!mounted) return;
      setState(() {
        final idx = _notifications.indexWhere((x) => x.id == n.id);
        if (idx >= 0) {
          final old = _notifications[idx];
          _notifications[idx] = AppNotification(
            id: old.id, userId: old.userId, title: old.title, body: old.body,
            referenceType: old.referenceType, referenceId: old.referenceId,
            readAt: DateTime.now(), createdAt: old.createdAt,
          );
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAll = true);
    try {
      await _repo.markAllRead();
      if (!mounted) return;
      setState(() {
        _notifications = _notifications.map((n) => AppNotification(
          id: n.id, userId: n.userId, title: n.title, body: n.body,
          referenceType: n.referenceType, referenceId: n.referenceId,
          readAt: n.readAt ?? DateTime.now(), createdAt: n.createdAt,
        )).toList();
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  Future<void> _delete(AppNotification n) async {
    try {
      await _repo.deleteNotification(n.id);
      if (!mounted) return;
      setState(() => _notifications.removeWhere((x) => x.id == n.id));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la notificacion.')),
      );
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).toList();

    return DefaultTabController(
      length: 2,
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    'Notificaciones',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _isMarkingAll ? null : _markAllRead,
                      child: Text(
                        _isMarkingAll ? 'Marcando...' : 'Marcar todas',
                        style: const TextStyle(color: AppColors.brand, fontSize: 13),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [Tab(text: 'Todas'), Tab(text: 'No leidas')],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.brand))
                    : TabBarView(
                        children: [
                          _NotificationsList(
                            notifications: _notifications,
                            onMarkRead: _markRead,
                            onDelete: _delete,
                          ),
                          _NotificationsList(
                            notifications: unread,
                            onMarkRead: _markRead,
                            onDelete: _delete,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Notifications list ───────────────────────────────────────────────────────

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.notifications,
    required this.onMarkRead,
    required this.onDelete,
  });

  final List<AppNotification> notifications;
  final Future<void> Function(AppNotification) onMarkRead;
  final Future<void> Function(AppNotification) onDelete;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Text(
          'No hay notificaciones.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) {
        final n = notifications[index];
        return Dismissible(
          key: ValueKey(n.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_rounded, color: AppColors.error),
          ),
          onDismissed: (_) => onDelete(n),
          child: GestureDetector(
            onTap: () {
              onMarkRead(n);
              _showNotifDetail(context, n);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: n.isRead ? AppColors.surfaceStrong : AppColors.activeSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: n.isRead ? AppColors.border : AppColors.brand.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: n.isRead ? AppColors.border : AppColors.activeSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      n.isRead ? Icons.notifications_rounded : Icons.notifications_active_rounded,
                      color: n.isRead ? AppColors.textSecondary : AppColors.brand,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(n.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!n.isRead)
                    Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(top: 6, left: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}

// ── Notification detail sheet ────────────────────────────────────────────────

void _showNotifDetail(BuildContext context, AppNotification n) {
  final body = n.body.toLowerCase();
  final title = n.title.toLowerCase();
  final Color color;
  final IconData icon;
  if (body.contains('confirmada') || title.contains('confirmada')) {
    color = const Color(0xFF22C55E); // success
    icon = Icons.check_circle_rounded;
  } else if (body.contains('rechazada') || title.contains('rechazada')) {
    color = const Color(0xFFEF4444); // error
    icon = Icons.cancel_rounded;
  } else {
    color = AppColors.brand;
    icon = Icons.notifications_rounded;
  }

  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 44, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999))),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(n.title,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text(n.body, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.6)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Auth action handler ──────────────────────────────────────────────────────

Future<void> _handleGlobalHeaderAction(
  BuildContext context,
  _GlobalHeaderMenuAction action,
) async {
  switch (action) {
    case _GlobalHeaderMenuAction.profile:
      Navigator.of(context).pushNamed(AppRoutes.profile);
      return;
    case _GlobalHeaderMenuAction.signOut:
      final repository = await AuthRepositoryFactory.create();
      await repository.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
  }
}
