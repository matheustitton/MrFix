import '../../domain/entities/entities.dart';

// ── UserModel ──────────────────────────────────────────────────────────────
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.gender,
    super.phone,
    super.averageRating,
    super.ratingCount,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:            json['id'] ?? '',
    name:          json['name'] ?? '',
    email:         json['email'] ?? '',
    role:          json['role'] ?? 'client',
    gender:        json['gender'],
    phone:         json['phone'],
    averageRating: (json['average_rating'] ?? 0).toDouble(),
    ratingCount:   json['rating_count'] ?? 0,
    avatarUrl:     json['avatar_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'role': role,
    'gender': gender, 'phone': phone,
    'average_rating': averageRating, 'rating_count': ratingCount,
  };
}

// ── ServiceCategoryModel ───────────────────────────────────────────────────
class ServiceCategoryModel extends ServiceCategoryEntity {
  const ServiceCategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) =>
    ServiceCategoryModel(
      id:          json['id'] ?? '',
      name:        json['name'] ?? '',
      description: json['description'],
      icon:        json['icon'],
    );
}

// ── ServiceRequestModel ────────────────────────────────────────────────────
class ServiceRequestModel extends ServiceRequestEntity {
  const ServiceRequestModel({
    required super.id,
    required super.title,
    super.description,
    required super.address,
    required super.status,
    required super.preferredGender,
    super.client,
    super.provider,
    super.category,
    super.scheduledAt,
    super.completedAt,
    required super.createdAt,
    super.agreedPrice,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) =>
    ServiceRequestModel(
      id:              json['id'] ?? '',
      title:           json['title'] ?? '',
      description:     json['description'],
      address:         json['address'] ?? '',
      status:          json['status'] ?? 'pending',
      preferredGender: json['preferred_gender'] ?? 'any',
      client:   json['client']   != null ? UserModel.fromJson(json['client'])   : null,
      provider: json['provider'] != null ? UserModel.fromJson(json['provider']) : null,
      category: json['category'] != null ? ServiceCategoryModel.fromJson(json['category']) : null,
      scheduledAt:  json['scheduled_at']  != null ? DateTime.tryParse(json['scheduled_at'])  : null,
      completedAt:  json['completed_at']  != null ? DateTime.tryParse(json['completed_at'])  : null,
      createdAt:    json['createdAt']      != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      agreedPrice:  json['agreed_price']  != null ? (json['agreed_price'] as num).toDouble() : null,
    );
}
// ── AppNotificationModel ───────────────────────────────────────────────────
class AppNotificationModel extends AppNotificationEntity {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    super.requestId,
    required super.read,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
    AppNotificationModel(
      id:        json['id'] ?? '',
      title:     json['title'] ?? '',
      body:      json['body'] ?? json['message'] ?? '',
      type:      json['type'] ?? 'general',
      requestId: json['request_id'] ?? json['service_request_id'],
      read:      json['read'] ?? json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
}