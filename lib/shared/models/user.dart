/// Represents an authenticated user's profile data.
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicUrl;
  final String? address;
  final String? city;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicUrl,
    this.address,
    this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:            json['id']?.toString()             ?? '',
      name:          json['name']?.toString()           ?? 'User',
      email:         json['email']?.toString()          ?? '',
      phone:         json['phone']?.toString()          ?? '',
      profilePicUrl: json['profile_pic_url'] as String?,
      address:       json['address'] as String?,
      city:          json['city'] as String?,
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
  }) {
    return User(
      id:            id            ?? this.id,
      name:          name          ?? this.name,
      email:         email         ?? this.email,
      phone:         phone         ?? this.phone,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      address:       address       ?? this.address,
      city:          city          ?? this.city,
    );
  }
}
