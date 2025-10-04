class Club {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? category;
  final String? contactEmail;
  final String? contactPhone;
  final int memberCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Club({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.category,
    this.contactEmail,
    this.contactPhone,
    this.memberCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      category: json['category'] as String?,
      contactEmail: json['contact_email'] as String?,
      contactPhone: json['contact_phone'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'category': category,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'member_count': memberCount,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Club copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? category,
    String? contactEmail,
    String? contactPhone,
    int? memberCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Club(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      category: category ?? this.category,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      memberCount: memberCount ?? this.memberCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
