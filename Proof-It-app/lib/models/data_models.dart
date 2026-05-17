enum UserRole { Admin, PIC, Member }

class User {
  String id;
  String username;
  String email;
  String password;
  UserRole role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });

  // ✅ Ubah dari static Object? menjadi factory User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password:
          json['password_hash'] ?? '', // Sesuaikan dengan nama kolom di DB
      role: _parseRole(json['role']),
    );
  }

  // Helper untuk mengubah String dari DB menjadi Enum di Flutter
  static UserRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'Admin':
        return UserRole.Admin;
      case 'PIC':
        return UserRole.PIC;
      default:
        return UserRole.Member;
    }
  }
}

class EventModel {
  String id;
  String title;
  String description;
  String status;
  DateTime date;
  String location;
  String picEmail;
  List<String> teamEmails;
  List<String> attachments;

  EventModel(
    this.id,
    this.title,
    this.description,
    this.status,
    this.date,
    this.location,
    this.picEmail,
    this.teamEmails, {
    this.attachments = const [],
  });
}

class RoadmapTask {
  String id;
  String projectId;
  String title;
  String description;
  String status; // 'To Do', 'In Progress', 'Done'
  DateTime start;
  DateTime end;
  double progress; // 0.0 - 1.0

  RoadmapTask({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.start,
    required this.end,
    this.progress = 0.0,
  });
}
