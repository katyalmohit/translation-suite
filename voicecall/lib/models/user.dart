class User {
  final String uid;
  final Map<String, dynamic> userDetails;
  final List<Map<String, dynamic>> contacts;
  final List<Map<String, dynamic>> callLogs;

  User({
    required this.uid,
    required this.userDetails,
    this.contacts = const [],
    this.callLogs = const [],

  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userDetails': userDetails,
      'contacts': contacts,
      'callLogs': callLogs,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      userDetails: map['userDetails']?? {},
      contacts: List<Map<String, dynamic>>.from(map['contacts'] ?? []),
      callLogs: List<Map<String, dynamic>>.from(map['callLogs'] ?? []),
    );
  }
}
