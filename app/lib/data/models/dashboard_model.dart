class DashboardData {
  final DashboardUser user;
  final List<BannerItem> banners;
  final ReminderItem? reminder;
  final List<EventItem> events;

  DashboardData({
    required this.user,
    required this.banners,
    this.reminder,
    required this.events,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: DashboardUser.fromJson(json['user']),
      banners: (json['banners'] as List).map((i) => BannerItem.fromJson(i)).toList(),
      reminder: json['reminder'] != null ? ReminderItem.fromJson(json['reminder']) : null,
      events: (json['events'] as List).map((i) => EventItem.fromJson(i)).toList(),
    );  
  }
}

class DashboardUser {
  final String name;
  final double weightLost;

  DashboardUser({required this.name, required this.weightLost});

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      name: json['name'] ?? '',
      weightLost: (json['weight_lost'] ?? 0).toDouble(),
    );
  }
}

class BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;

  BannerItem({required this.title, required this.subtitle, required this.imageUrl});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class ReminderItem {
  final String title;
  final String message;

  ReminderItem({required this.title, required this.message});

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      title: json['title'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class EventItem {
  final String title;
  final String dateFormatted;

  EventItem({required this.title, required this.dateFormatted});

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      title: json['title'] ?? '',
      dateFormatted: json['date_formatted'] ?? '',
    );
  }
}