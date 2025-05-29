class Message {
  final String key;
  final dynamic value;

  Message({required this.key, required this.value});

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };

  static Message fromJson(Map<String, dynamic> json) => Message(
        key: json['key'],
        value: json['value'],
      );
}
