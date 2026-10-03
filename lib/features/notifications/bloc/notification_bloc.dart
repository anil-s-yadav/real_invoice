import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/notification_repository.dart';
import '../domain/notification_model.dart';
import 'dart:async';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class SetupNotificationsEvent extends NotificationEvent {}

class LoadNotificationsEvent extends NotificationEvent {}

class NotificationsUpdatedEvent extends NotificationEvent {
  final List<AppNotification> notifications;
  const NotificationsUpdatedEvent(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String id;
  const MarkNotificationAsReadEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;

  const NotificationLoaded(this.notifications);

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  StreamSubscription? _notificationsSubscription;

  NotificationBloc({required this.repository}) : super(NotificationInitial()) {
    on<SetupNotificationsEvent>(_onSetupNotifications);
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
    on<MarkNotificationAsReadEvent>(_onMarkAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllAsRead);
  }

  Future<void> _onSetupNotifications(
    SetupNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.setupFCMToken();
    add(LoadNotificationsEvent());
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    await emit.forEach<List<AppNotification>>(
      repository.getNotificationsStream(),
      onData: (notifications) => NotificationLoaded(notifications),
      onError: (error, _) => NotificationError(error.toString()),
    );
  }

  void _onNotificationsUpdated(
    NotificationsUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoaded(event.notifications));
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAsRead(event.id);
  }

  Future<void> _onMarkAllAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAllAsRead();
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
