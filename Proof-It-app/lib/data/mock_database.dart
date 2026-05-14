import '../models/data_models.dart';

class MockDatabase {
  // USERS (SAYA KEMBALIKAN KE EMAIL @test.com)
  static final List<User> _users = [
    // Akun Admin
    User(
      id: "1",
      username: "Super Admin",
      email: "admin@proofit.com",
      password: "123",
      role: UserRole.Admin,
    ),

    // Akun PIC (Kembali ke pic@test.com)
    User(
      id: "2",
      username: "Siti Manager",
      email: "pic@test.com",
      password: "123",
      role: UserRole.PIC,
    ),

    // Akun Member/Staff (Kembali ke member@test.com)
    User(
      id: "3",
      username: "Andi Staff",
      email: "member@test.com",
      password: "123",
      role: UserRole.Member,
    ),

    // Akun Tambahan
    User(
      id: "4",
      username: "Budi Senior",
      email: "budi@test.com",
      password: "123",
      role: UserRole.Member,
    ),
  ];

  // PROJECTS (DATA DISESUAIKAN DENGAN EMAIL DI ATAS)
  static final List<EventModel> _events = [
    EventModel(
      "1",
      "Grand Launching App",
      "Event besar peluncuran.",
      "Upcoming",
      DateTime.now().add(const Duration(days: 30)),
      "Grand Ballroom",
      "pic@test.com", // PIC Email
      ["pic@test.com", "member@test.com", "budi@test.com"], // Team Emails
      attachments: ["venue.jpg"],
    ),
    EventModel(
      "2",
      "Internal Training",
      "Pelatihan React Native.",
      "On Progress",
      DateTime.now().add(const Duration(days: 5)),
      "Meeting Room A",
      "pic@test.com", // PIC Email
      ["pic@test.com", "member@test.com"], // Team Emails
    ),
  ];

  // ROADMAP TASKS
  static final List<RoadmapTask> _tasks = [
    RoadmapTask(
      id: "1",
      projectId: "1",
      title: "Sewa Tempat",
      description: "Bayar DP",
      status: "Done",
      start: DateTime.now().subtract(const Duration(days: 10)),
      end: DateTime.now().subtract(const Duration(days: 5)),
      progress: 1.0,
    ),
    RoadmapTask(
      id: "2",
      projectId: "1",
      title: "Cetak Banner",
      description: "Vendor X",
      status: "In Progress",
      start: DateTime.now().subtract(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 5)),
      progress: 0.6,
    ),
    RoadmapTask(
      id: "3",
      projectId: "2",
      title: "Siapkan Modul",
      description: "PDF Modul",
      status: "To Do",
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 3)),
      progress: 0.0,
    ),
    RoadmapTask(
      id: "4",
      projectId: "2",
      title: "Kontrak Trainer",
      description: "Harus sign kemarin",
      status: "In Progress",
      start: DateTime.now().subtract(const Duration(days: 15)),
      end: DateTime.now().subtract(const Duration(days: 1)),
      progress: 0.2,
    ),
  ];

  // --- METHODS (SAMA SEPERTI SEBELUMNYA) ---
  static User? login(String email, String pass) {
    try {
      return _users.firstWhere((u) => u.email == email && u.password == pass);
    } catch (e) {
      return null;
    }
  }

  static List<EventModel> getEvents() => _events;
  static EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<RoadmapTask> getAllTasks() => _tasks;
  static List<RoadmapTask> getTasksByProject(String pid) =>
      _tasks.where((t) => t.projectId == pid).toList();

  static List<User> getUsers() => _users;
  static User? getUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  // CRUD
  static void addEvent(EventModel e) => _events.add(e);
  static void updateEvent(String id, EventModel newEvent) {
    int i = _events.indexWhere((e) => e.id == id);
    if (i != -1) _events[i] = newEvent;
  }

  static void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    _tasks.removeWhere((t) => t.projectId == id);
  }

  static void addTask(RoadmapTask t) => _tasks.add(t);

  // Update Task Full
  static void updateTask(RoadmapTask t) {
    int i = _tasks.indexWhere((x) => x.id == t.id);
    if (i != -1) _tasks[i] = t;
  }

  static void deleteTask(String id) => _tasks.removeWhere((t) => t.id == id);

  static void addUser(User u) => _users.add(u);
  static void updateUser(User u) {
    int i = _users.indexWhere((x) => x.id == u.id);
    if (i != -1) _users[i] = u;
  }
}

class AuthSession {
  static User? currentUser;
}