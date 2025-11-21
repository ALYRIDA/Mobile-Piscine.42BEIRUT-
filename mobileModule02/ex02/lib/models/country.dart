
class Country {
  final String name;
  final String flag;

  Country({required this.name, required this.flag});

  factory Country.fromJson(Map<String, dynamic> json) {
    final name = (json['name']?['common'] ?? '').toString();
    final flag = json['flag']?.toString() ?? '';
    return Country(name: name, flag: flag);
  }
}
