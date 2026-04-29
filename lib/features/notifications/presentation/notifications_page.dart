import 'package:flutter/material.dart';
import 'package:petsafe_movil_app/app/theme/app_colors.dart';
import 'package:petsafe_movil_app/core/network/api_failure.dart';
import 'package:petsafe_movil_app/core/widgets/feature_page_scaffold.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_models.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_repository.dart';
import 'package:petsafe_movil_app/features/notifications/data/notification_repository_factory.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationRepository _repository;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;
  String? _errorMessage;

  DateTime? _lastLoaded;
  bool _wasTickerActive = false;
  static const _staleDuration = Duration(seconds: 45);

  @override
  void initState() {
    super.initState();
    _repository = NotificationRepositoryFactory.create();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isNowActive = TickerMode.of(context);
    if (isNowActive && !_wasTickerActive) {
      final stale = _lastLoaded == null ||
          DateTime.now().difference(_lastLoaded!) > _staleDuration;
      if (stale) _load();
    }
    _wasTickerActive = isNowActive;
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _repository.loadMine();
      if (mounted) setState(() {
        _notifications = items;
        _lastLoaded = DateTime.now();
      });
    } on ApiFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (_) {
      if (mounted) setState(() => _errorMessage = 'No se pudieron cargar las notificaciones.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markRead(AppNotification notification) async {
    if (notification.isRead) return;
    try {
      await _repository.markRead(notification.id);
      if (!mounted) return;
      setState(() {
        final idx = _notifications.indexWhere((n) => n.id == notification.id);
        if (idx >= 0) {
          final old = _notifications[idx];
          _notifications[idx] = AppNotification(
            id: old.id,
            userId: old.userId,
            title: old.title,
            body: old.body,
            referenceType: old.referenceType,
            referenceId: old.referenceId,
            readAt: DateTime.now(),
            createdAt: old.createdAt,
          );
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    setState(() => _isMarkingAll = true);
    try {
      await _repository.markAllRead();
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

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return FeaturePageScaffold(
      title: 'Notificaciones',
      appBarActions: [
        if (_unreadCount > 0)
          TextButton(
            onPressed: _isMarkingAll ? null : _markAllRead,
            child: Text(
              _isMarkingAll ? 'Marcando...' : 'Marcar todas',
              style: const TextStyle(color: AppColors.brand, fontSize: 13),
            ),
          ),
      ],
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.brand));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.notifications_none_rounded, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Sin notificaciones', textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Aqui veras cuando el veterinario responda tus solicitudes de cita.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.45)),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: _notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _notificationCard(_notifications[index]),
    );
  }

  _NotifKind _kindOf(AppNotification n) {
    final body = n.body.toLowerCase();
    final title = n.title.toLowerCase();
    if (body.contains('confirmada') || title.contains('confirmada')) return _NotifKind.confirmed;
    if (body.contains('rechazada') || title.contains('rechazada')) return _NotifKind.rejected;
    return _NotifKind.info;
  }

  Widget _notificationCard(AppNotification notification) {
    final isUnread = !notification.isRead;
    final kind = _kindOf(notification);

    return GestureDetector(
      onTap: () {
        _markRead(notification);
        _showDetail(notification, kind);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread
              ? kind.bgColor.withOpacity(0.08)
              : AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? kind.color.withOpacity(0.35) : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kind.color.withOpacity(isUnread ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(kind.icon, color: kind.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                            color: kind.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(color: kind.color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _formatDate(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Ver detalle →',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kind.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(AppNotification n, _NotifKind kind) {
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
              child: Container(
                width: 44, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: kind.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(kind.icon, color: kind.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    n.title,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: kind.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kind.bgColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kind.color.withOpacity(0.2)),
              ),
              child: Text(
                n.body,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatDate(n.createdAt),
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

enum _NotifKind {
  confirmed,
  rejected,
  info;

  Color get color {
    switch (this) {
      case _NotifKind.confirmed: return AppColors.success;
      case _NotifKind.rejected: return AppColors.error;
      case _NotifKind.info: return AppColors.brand;
    }
  }

  Color get bgColor => color;

  IconData get icon {
    switch (this) {
      case _NotifKind.confirmed: return Icons.check_circle_rounded;
      case _NotifKind.rejected: return Icons.cancel_rounded;
      case _NotifKind.info: return Icons.notifications_rounded;
    }
  }
}
