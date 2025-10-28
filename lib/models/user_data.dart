class UserData {
  final String aadhaarNumber;
  final String rationCardNumber;
  final String name;
  final String fatherHusbandName;
  final DateTime dateOfBirth;
  final String gender;
  final String religion;
  final String caste;
  final String occupation;
  final double annualIncome;
  final int totalFamilyMembers;
  final String address;
  final bool isBPL;
  final bool hasBankAccount;
  final bool detailsSubmitted;

  UserData({
    required this.aadhaarNumber,
    required this.rationCardNumber,
    required this.name,
    required this.fatherHusbandName,
    required this.dateOfBirth,
    required this.gender,
    required this.religion,
    required this.caste,
    required this.occupation,
    required this.annualIncome,
    required this.totalFamilyMembers,
    required this.address,
    required this.isBPL,
    required this.hasBankAccount,
    this.detailsSubmitted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'aadhaarNumber': aadhaarNumber,
      'rationCardNumber': rationCardNumber,
      'name': name,
      'fatherHusbandName': fatherHusbandName,
      'dateOfBirth': dateOfBirth.millisecondsSinceEpoch,
      'gender': gender,
      'religion': religion,
      'caste': caste,
      'occupation': occupation,
      'annualIncome': annualIncome,
      'totalFamilyMembers': totalFamilyMembers,
      'address': address,
      'isBPL': isBPL,
      'hasBankAccount': hasBankAccount,
      'detailsSubmitted': detailsSubmitted,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      aadhaarNumber: map['aadhaarNumber'] ?? '',
      rationCardNumber: map['rationCardNumber'] ?? '',
      name: map['name'] ?? '',
      fatherHusbandName: map['fatherHusbandName'] ?? '',
      dateOfBirth: DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] ?? 0),
      gender: map['gender'] ?? '',
      religion: map['religion'] ?? '',
      caste: map['caste'] ?? '',
      occupation: map['occupation'] ?? '',
      annualIncome: (map['annualIncome'] ?? 0).toDouble(),
      totalFamilyMembers: map['totalFamilyMembers'] ?? 0,
      address: map['address'] ?? '',
      isBPL: map['isBPL'] ?? false,
      hasBankAccount: map['hasBankAccount'] ?? false,
      detailsSubmitted: map['detailsSubmitted'] ?? false,
    );
  }

  UserData copyWith({
    String? aadhaarNumber,
    String? rationCardNumber,
    String? name,
    String? fatherHusbandName,
    DateTime? dateOfBirth,
    String? gender,
    String? religion,
    String? caste,
    String? occupation,
    double? annualIncome,
    int? totalFamilyMembers,
    String? address,
    bool? isBPL,
    bool? hasBankAccount,
    bool? detailsSubmitted,
  }) {
    return UserData(
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      rationCardNumber: rationCardNumber ?? this.rationCardNumber,
      name: name ?? this.name,
      fatherHusbandName: fatherHusbandName ?? this.fatherHusbandName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      religion: religion ?? this.religion,
      caste: caste ?? this.caste,
      occupation: occupation ?? this.occupation,
      annualIncome: annualIncome ?? this.annualIncome,
      totalFamilyMembers: totalFamilyMembers ?? this.totalFamilyMembers,
      address: address ?? this.address,
      isBPL: isBPL ?? this.isBPL,
      hasBankAccount: hasBankAccount ?? this.hasBankAccount,
      detailsSubmitted: detailsSubmitted ?? this.detailsSubmitted,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
