// ── User Entity ───────────────────────────────────────────────────────────────
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? gender;
  final String? phone;
  final double averageRating;
  final int ratingCount;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.gender,
    this.phone,
    this.averageRating = 0,
    this.ratingCount = 0,
    this.avatarUrl,
  });
}

// ── ServiceCategory Entity ────────────────────────────────────────────────────
class ServiceCategoryEntity {
  final String id;
  final String name;
  final String? description;
  final String? icon;

  const ServiceCategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.icon,
  });
}

// ── ServiceRequest Entity ─────────────────────────────────────────────────────
class ServiceRequestEntity {
  final String id;
  final String title;
  final String? description;
  final String address;
  final String status;
  final String preferredGender;
  final UserEntity? client;
  final UserEntity? provider;
  final ServiceCategoryEntity? category;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final double? agreedPrice;

  const ServiceRequestEntity({
    required this.id,
    required this.title,
    this.description,
    required this.address,
    required this.status,
    required this.preferredGender,
    this.client,
    this.provider,
    this.category,
    this.scheduledAt,
    this.completedAt,
    required this.createdAt,
    this.agreedPrice,
  });

  bool get isPending     => status == 'pending';
  bool get isAccepted    => status == 'accepted';
  bool get isInProgress  => status == 'in_progress';
  bool get isCompleted   => status == 'completed';
  bool get isCancelled   => status == 'cancelled';
  bool get canBeCancelled => !isCompleted && !isCancelled;
}
// ── Notification Entity ───────────────────────────────────────────────────────
class AppNotificationEntity {
  final String id;
  final String title;
  final String body;
  final String type; // 'request_accepted', 'request_started', 'request_completed', 'new_rating'
  final String? requestId;
  final bool read;
  final DateTime createdAt;

  const AppNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.requestId,
    required this.read,
    required this.createdAt,
  });
}