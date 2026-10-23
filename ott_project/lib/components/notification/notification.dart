

class Notifications {
  final String title;
  final String message;
  final String image;

  Notifications({
    required this.title,
    required this.message,
    required this.image,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
        title: json['title'],
        message: json['message'],
        image: json['notimage']);
  }
}
