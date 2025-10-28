class UserData {
  final String uid;
  final String aadhaarNumber;
  final String rationCardNumber;
  final String name;
  final String surname;
  final String fatherHusbandName;
  final DateTime dateOfBirth;
  final String gender;
  final String religion;
  final String caste;
  final String occupation;
  final int annualIncome;
  final int totalFamilyMembers;
  final String address;
  final bool isBpl;
  final bool hasBankAccount;

  UserData({
    required this.uid,
    required this.aadhaarNumber,
    required this.rationCardNumber,
    required this.name,
    required this.surname,
    required this.fatherHusbandName,
    required this.dateOfBirth,
    required this.gender,
    required this.religion,
    required this.caste,
    required this.occupation,
    required this.annualIncome,
    required this.totalFamilyMembers,
    required this.address,
    required this.isBpl,
    required this.hasBankAccount,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'aadhaarNumber': aadhaarNumber,
      'rationCardNumber': rationCardNumber,
      'name': name,
      'surname': surname,
      'fatherHusbandName': fatherHusbandName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'religion': religion,
      'caste': caste,
      'occupation': occupation,
      'annualIncome': annualIncome,
      'totalFamilyMembers': totalFamilyMembers,
      'address': address,
      'isBpl': isBpl,
      'hasBankAccount': hasBankAccount,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      uid: map['uid'],
      aadhaarNumber: map['aadhaarNumber'],
      rationCardNumber: map['rationCardNumber'],
      name: map['name'],
      surname: map['surname'],
      fatherHusbandName: map['fatherHusbandName'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      gender: map['gender'],
      religion: map['religion'],
      caste: map['caste'],
      occupation: map['occupation'],
      annualIncome: map['annualIncome'],
      totalFamilyMembers: map['totalFamilyMembers'],
      address: map['address'],
      isBpl: map['isBpl'],
      hasBankAccount: map['hasBankAccount'],
    );
  }
}
