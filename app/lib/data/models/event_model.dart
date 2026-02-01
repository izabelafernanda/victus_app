class EventModel {
  final String title;
  final String type;
  final String dateLabel;
  // Podemos adicionar data real depois para o calendário
  final DateTime? fullDate; 

  EventModel({
    required this.title, 
    required this.type, 
    required this.dateLabel,
    this.fullDate,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      dateLabel: json['date_label'] ?? '',
      // Se o PHP mandar a data completa (ex: '2026-05-23'), podemos converter:
      fullDate: json['event_date'] != null ? DateTime.tryParse(json['event_date']) : null,
    );
  }
}