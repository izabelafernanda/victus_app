import 'event_model.dart';

class DashboardModel {
  final DailyTip? dailyTip;
  final DailyQuote? dailyQuote;
  final double weightLost;
  // Agora usa o EventModel independente
  final List<EventModel> events; 

  DashboardModel({
    this.dailyTip,
    this.dailyQuote,
    required this.weightLost,
    required this.events,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      dailyTip: json['daily_tip'] != null ? DailyTip.fromJson(json['daily_tip']) : null,
      dailyQuote: json['daily_quote'] != null ? DailyQuote.fromJson(json['daily_quote']) : null,
      weightLost: (json['weight_lost'] ?? 0).toDouble(),
      
      // Mapeia usando a classe externa
      events: (json['events'] as List?)
              ?.map((i) => EventModel.fromJson(i))
              .toList() ?? 
              [],
    );
  }
}

// --- Classes menores exclusivas do Dashboard podem ficar aqui ---

class DailyTip {
  final String? title;
  final String message;
  final String backgroundColor;

  DailyTip({this.title, required this.message, required this.backgroundColor});

  factory DailyTip.fromJson(Map<String, dynamic> json) {
    return DailyTip(
      title: json['title'],
      message: json['message'] ?? '',
      backgroundColor: json['background_color'] ?? '0xFFF8E8E8',
    );
  }
}

class DailyQuote {
  final String message;

  DailyQuote({required this.message});

  factory DailyQuote.fromJson(Map<String, dynamic> json) {
    return DailyQuote(
      message: json['message'] ?? '',
    );
  }
}

// --- APAGUEI A CLASSE 'EventItem' DAQUI POIS JÁ EXISTE NO event_model.dart ---