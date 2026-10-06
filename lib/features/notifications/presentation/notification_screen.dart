import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:invoz/core/constants/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../domain/notification_model.dart';
import '../../subscription/presentation/plan_info_screen.dart';
import '../../documents/data/document_repository.dart';
import '../../documents/presentation/pdf_preview_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              context.read<NotificationBloc>().add(
                MarkAllNotificationsAsReadEvent(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(notification: notification);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: notification.isRead
          ? (isDark ? Colors.transparent : Colors.white)
          : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4)),
      leading: _buildIcon(),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(notification.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationBloc>().add(
            MarkNotificationAsReadEvent(notification.id),
          );
        }
        _handleTap(context);
      },
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.subscription:
        iconData = Icons.workspace_premium;
        iconColor = AppColors.primary;
        break;
      case NotificationType.invoice:
      case NotificationType.document:
        iconData = Icons.receipt_long;
        iconColor = AppColors.statusOverdueText;
        break;
      case NotificationType.system:
        iconData = Icons.info_outline;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    if (notification.type == NotificationType.subscription) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PlanInfoScreen()),
      );
    } else if (notification.type == NotificationType.invoice ||
        notification.type == NotificationType.document) {
      final docId = notification.relatedId;
      if (docId == null || docId.isEmpty) return;

      // Show a quick loading indicator
      bool isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) isDialogShowing = false;
            },
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      ).then((_) => isDialogShowing = false);

      try {
        final repo = context.read<DocumentRepository>();
        final document = await repo.getDocumentById(docId);

        if (context.mounted) {
          if (isDialogShowing) {
            Navigator.pop(context); // Close loading dialog safely
          }
          if (document != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfPreviewScreen(document: document),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document not found or deleted.')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          if (isDialogShowing) Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error loading document: $e')));
        }
      }
    }
  }
}
