class User {
  final String uid;
  final String userName;
  final String email;
  final String phoneNumber;
  final String birthday;
  final String location;

  User({
    required this.uid,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    required this.birthday,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
      'location': location,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthday: map['birthday'] ?? '',
      location: map['location'] ?? '',
    );
  }
}
