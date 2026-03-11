class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicUrl;
  final String? address;
  final String? city;

  User({
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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? 'Phone not provided',
      profilePicUrl: json['profile_pic_url'],
      address: json['address'],
      city: json['city'],
    );
  }
}
