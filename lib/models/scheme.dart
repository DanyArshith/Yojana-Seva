class Scheme {
  final String id;
  final String name;
  final String ageRange;
  final String gender;
  final bool requiresRationCard;
  final String description;
  final String link;
  final int? ageMin;
  final int? ageMax;
  final double? incomeLimit;
  final String? category;

  Scheme({
    required this.id,
    required this.name,
    required this.ageRange,
    required this.gender,
    required this.requiresRationCard,
    required this.description,
    required this.link,
    this.ageMin,
    this.ageMax,
    this.incomeLimit,
    this.category,
  });

  factory Scheme.fromMap(Map<String, dynamic> data, String id) {
    return Scheme(
      id: id,
      name: data['name'] ?? '',
      ageRange: data['ageRange'] ?? '',
      gender: data['gender'] ?? '',
      requiresRationCard: data['requiresRationCard'] ?? false,
      description: data['description'] ?? '',
      link: data['link'] ?? '',
      ageMin: data['age_min'],
      ageMax: data['age_max'],
      incomeLimit: data['income_limit']?.toDouble(),
      category: data['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ageRange': ageRange,
      'gender': gender,
      'requiresRationCard': requiresRationCard,
      'description': description,
      'link': link,
      'age_min': ageMin,
      'age_max': ageMax,
      'income_limit': incomeLimit,
      'category': category,
    };
  }
}
