/// Represents an authenticated user's profile data.
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicUrl;
  final String? address;
  final String? city;
  final bool isAvailable;
  final String? role;
  /// Worker-specific details stored as a JSONB column on the backend.
  /// Contains: bio, category_ids, experience_years, hourly_rate.
  final Map<String, dynamic>? workDetails;
  /// Skills list for workers (e.g. ["Interior Painting", "Waterproofing"]).
  final List<String> skills;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicUrl,
    this.address,
    this.city,
    this.isAvailable = true,
    this.role,
    this.workDetails,
    this.skills = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Parse skills: the backend stores them as a JSON array of strings
    List<String> parsedSkills = [];
    final rawSkills = json['skills'];
    if (rawSkills is List) {
      parsedSkills = rawSkills.map((s) => s.toString()).toList();
    }
    return User(
      id:            json['id']?.toString()             ?? '',
      name:          json['name']?.toString()           ?? 'User',
      email:         json['email']?.toString()          ?? '',
      phone:         json['phone']?.toString()          ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      address:       json['address'] as String?,
      city:          json['city'] as String?,
      isAvailable:   json['is_available'] as bool? ?? true,
      role:          json['role'] as String?,
      workDetails:   json['work_details'] as Map<String, dynamic>?,
      skills:        parsedSkills,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':              id,
    'name':            name,
    'email':           email,
    'phone':           phone,
    'profile_pic_url': profilePicUrl,
    'address':         address,
    'city':            city,
    'is_available':    isAvailable,
    'role':            role,
    'work_details':    workDetails,
    'skills':          skills,
  };

  /// Returns a new [User] with the specified fields replaced.
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePicUrl,
    String? address,
    String? city,
    bool? isAvailable,
    String? role,
    Map<String, dynamic>? workDetails,
    List<String>? skills,
  }) {
    return User(
      id:            id            ?? this.id,
      name:          name          ?? this.name,
      email:         email         ?? this.email,
      phone:         phone         ?? this.phone,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      address:       address       ?? this.address,
      city:          city          ?? this.city,
      isAvailable:   isAvailable   ?? this.isAvailable,
      role:          role          ?? this.role,
      workDetails:   workDetails   ?? this.workDetails,
      skills:        skills        ?? this.skills,
    );
  }
}
