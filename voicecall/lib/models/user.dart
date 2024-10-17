class User {
  final String uid;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String birthday;
  final String location;

  User({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.birthday,
    required this.location,
  });

  // Convert the user model to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'birthday': birthday,
      'location': location,
    };
  }
}
