class User {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String birthday;
  final String location;

  User({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.birthday,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
      'location': location,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthday: map['birthday'] ?? '',
      location: map['location'] ?? '',
    );
  }
}
