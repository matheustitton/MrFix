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
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at']) : null,
      createdAt:   json['createdAt']    != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      agreedPrice: json['agreed_price'] != null ? (json['agreed_price'] as num).toDouble() : null,
    );
}

// ── ProviderSpecialtyModel ─────────────────────────────────────────────────
class ProviderSpecialtyModel extends ProviderSpecialtyEntity {
  const ProviderSpecialtyModel({
    required super.id,
    required super.categoryId,
    required super.categoryName,
    super.category,
    super.averagePrice,
    super.experienceYears,
    super.bio,
    super.isAvailable,
  });

  factory ProviderSpecialtyModel.fromJson(Map<String, dynamic> json) =>
    ProviderSpecialtyModel(
      id:              json['id'] ?? '',
      categoryId:      json['category_id'] ?? '',
      categoryName:    json['category']?['name'] ?? json['category_name'] ?? '',
      category:        json['category'] != null
          ? ServiceCategoryModel.fromJson(json['category'])
          : null,
      averagePrice:    json['average_price'] != null
          ? (json['average_price'] as num).toDouble()
          : null,
      experienceYears: json['experience_years'] ?? 0,
      bio:             json['bio'],
      isAvailable:     json['is_available'] ?? true,
    );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'average_price': averagePrice,
    'experience_years': experienceYears,
    'bio': bio,
  };
}