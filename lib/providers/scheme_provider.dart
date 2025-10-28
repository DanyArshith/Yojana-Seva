import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yojana_seva/models/scheme.dart';
import 'package:yojana_seva/models/user_data.dart';

class SchemeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Scheme> _allSchemes = [];
  List<Scheme> _personalizedSchemes = [];
  List<Scheme> _filteredSchemes = [];
  bool _isLoading = false;

  List<Scheme> get allSchemes => _allSchemes;
  List<Scheme> get personalizedSchemes => _personalizedSchemes;
  List<Scheme> get filteredSchemes => _filteredSchemes;
  bool get isLoading => _isLoading;

  Future<void> loadSchemes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final QuerySnapshot snapshot =
          await _firestore.collection('schemes').get();
      _allSchemes = snapshot.docs
          .map((doc) =>
              Scheme.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Initialize with all schemes, will be filtered when user data is available
      _personalizedSchemes = List.from(_allSchemes);
      _filteredSchemes = List.from(_allSchemes);
    } catch (e) {
      print('Error loading schemes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPersonalizedSchemes(UserData? userData) async {
    if (userData == null || !userData.detailsSubmitted) {
      _personalizedSchemes = [];
      _filteredSchemes = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      _personalizedSchemes = _allSchemes.where((scheme) {
        return _isEligibleForScheme(scheme, userData);
      }).toList();

      // Set filtered schemes to personalized schemes initially
      _filteredSchemes = List.from(_personalizedSchemes);
    } catch (e) {
      print('Error filtering schemes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchSchemes(String query) {
    // Only search if we have schemes loaded
    if (_allSchemes.isEmpty) {
      return;
    }

    // Always search within personalized schemes if they exist, otherwise search all schemes
    final baseSchemes =
        _personalizedSchemes.isNotEmpty ? _personalizedSchemes : _allSchemes;

    if (query.isEmpty) {
      // If no search query, show the base schemes (personalized if available)
      _filteredSchemes = List.from(baseSchemes);
    } else {
      // Search within the base schemes
      _filteredSchemes = baseSchemes.where((scheme) {
        return scheme.name.toLowerCase().contains(query.toLowerCase()) ||
            scheme.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  /// Reset search and show personalized schemes
  void resetSearch() {
    if (_personalizedSchemes.isNotEmpty) {
      _filteredSchemes = List.from(_personalizedSchemes);
    } else {
      _filteredSchemes = List.from(_allSchemes);
    }
    notifyListeners();
  }

  bool _isEligibleForScheme(Scheme scheme, UserData userData) {
    return isEligible(userData, scheme);
  }

  /// Comprehensive eligibility check based on user attributes and scheme requirements
  /// This method implements the eligibility logic as described in the requirements
  bool isEligible(UserData user, Scheme scheme) {
    final age = user.age;
    final gender = user.gender;
    final income = user.annualIncome;
    final category = user.caste;

    // Age eligibility check
    final ageOk = (scheme.ageMin == null || age >= scheme.ageMin!) &&
        (scheme.ageMax == null || age <= scheme.ageMax!);

    // Gender eligibility check
    final genderOk = (scheme.gender == 'Any' || scheme.gender == gender);

    // Income eligibility check
    final incomeOk =
        (scheme.incomeLimit == null || income <= scheme.incomeLimit!);

    // Category eligibility check - support multiple categories separated by "/"
    final categoryOk = (scheme.category == null ||
        scheme.category!.split('/').contains(category));

    // Ration card requirement check
    final rationCardOk =
        (!scheme.requiresRationCard || user.rationCardNumber.isNotEmpty);

    return ageOk && genderOk && incomeOk && categoryOk && rationCardOk;
  }

  /// Get detailed eligibility information for debugging
  Map<String, dynamic> getEligibilityDetails(UserData user, Scheme scheme) {
    final age = user.age;
    final gender = user.gender;
    final income = user.annualIncome;
    final category = user.caste;

    final ageOk = (scheme.ageMin == null || age >= scheme.ageMin!) &&
        (scheme.ageMax == null || age <= scheme.ageMax!);
    final genderOk = (scheme.gender == 'Any' || scheme.gender == gender);
    final incomeOk =
        (scheme.incomeLimit == null || income <= scheme.incomeLimit!);
    final categoryOk = (scheme.category == null || scheme.category == category);
    final rationCardOk =
        (!scheme.requiresRationCard || user.rationCardNumber.isNotEmpty);

    return {
      'schemeName': scheme.name,
      'ageCheck': {
        'userAge': age,
        'minAge': scheme.ageMin,
        'maxAge': scheme.ageMax,
        'passed': ageOk,
      },
      'genderCheck': {
        'userGender': gender,
        'requiredGender': scheme.gender,
        'passed': genderOk,
      },
      'incomeCheck': {
        'userIncome': income,
        'incomeLimit': scheme.incomeLimit,
        'passed': incomeOk,
      },
      'categoryCheck': {
        'userCategory': category,
        'requiredCategory': scheme.category,
        'passed': categoryOk,
      },
      'rationCardCheck': {
        'hasRationCard': user.rationCardNumber.isNotEmpty,
        'required': scheme.requiresRationCard,
        'passed': rationCardOk,
      },
      'overallEligible':
          ageOk && genderOk && incomeOk && categoryOk && rationCardOk,
    };
  }

  Future<void> addSampleSchemes() async {
    final List<Map<String, dynamic>> sampleSchemes = [
      {
        "name": "Sampoorna Poshana Plus",
        "ageRange": "0-6",
        "age_min": 0,
        "age_max": 6,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Nutrition and health support for children aged 0-6 and pregnant/lactating mothers to improve health outcomes.",
        "link": "https://www.ap.gov.in/sampoorna-poshana-plus"
      },
      {
        "name": "Thalliki Vandanam",
        "ageRange": "0-6",
        "age_min": 0,
        "age_max": 6,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Financial incentive to mothers of children (0-6 yrs) for early childhood care and development support.",
        "link": "https://www.ap.gov.in/thalliki-vandanam"
      },
      {
        "name": "Cheyutha",
        "ageRange": "45-60",
        "age_min": 45,
        "age_max": 60,
        "gender": "Female",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Scheme targeted at women aged 45-60 with ration card to provide financial assistance for livelihood enhancement.",
        "link": "https://www.ap.gov.in/cheyutha"
      },
      {
        "name": "Kapu Nestham",
        "ageRange": "45-60",
        "age_min": 45,
        "age_max": 60,
        "gender": "Female",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": "Kapu",
        "description":
            "Support for women aged between 45 and 60 from Kapu community (with ration card) to bolster social/welfare benefits.",
        "link": "https://www.ap.gov.in/kapu-nestham"
      },
      {
        "name": "Pension Kanuka",
        "ageRange": "60+",
        "age_min": 60,
        "age_max": null,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Old‐age pension scheme for citizens aged 60 or above, subject to holding a ration card.",
        "link": "https://www.ap.gov.in/pension-kanuka"
      },
      {
        "name": "Nirudyoga Bruthi",
        "ageRange": "22-35",
        "age_min": 22,
        "age_max": 35,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Unemployment allowance for youth between 22 and 35 who hold a ration card and meet eligibility criteria.",
        "link": "https://www.ap.gov.in/nirudyoga-bruthi"
      },
      {
        "name": "Vidyonnathi Scheme",
        "ageRange": "22-35",
        "age_min": 22,
        "age_max": 35,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Educational support scheme for youth aged 22-35 holding a ration card — coaching, skill development & higher education assistance.",
        "link": "https://www.ap.gov.in/vidyonnathi"
      },
      {
        "name": "Ammavodi Scheme",
        "ageRange": "3-17",
        "age_min": 3,
        "age_max": 17,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Educational support for children aged 3-17 whose families hold a ration card; aims to ensure school enrolment and attendance.",
        "link": "https://www.ap.gov.in/ammavodi"
      },
      {
        "name": "Fee Reimbursement Scheme",
        "ageRange": "18-21",
        "age_min": 18,
        "age_max": 21,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 200000.0,
        "category": null,
        "description":
            "Provides reimbursement of tuition/fees for students aged 18-21 with a ration card in order to promote higher education access.",
        "link": "https://www.ap.gov.in/fee-reimbursement"
      },
      {
        "name": "BC Welfare Scheme",
        "ageRange": "18-50",
        "age_min": 18,
        "age_max": 50,
        "gender": "Any",
        "requiresRationCard": true,
        "income_limit": 150000.0,
        "category": "BC",
        "description":
            "Special welfare scheme for Backward Classes (BC) community members aged 18-50 with income below 1.5 lakhs.",
        "link": "https://www.ap.gov.in/bc-welfare"
      },
      {
        "name": "SC/ST Scholarship",
        "ageRange": "16-25",
        "age_min": 16,
        "age_max": 25,
        "gender": "Any",
        "requiresRationCard": false,
        "income_limit": 100000.0,
        "category": "SC/ST",
        "description":
            "Educational scholarship for SC/ST students aged 16-25 with family income below 1 lakh.",
        "link": "https://www.ap.gov.in/sc-st-scholarship"
      }
    ];

    try {
      for (var schemeData in sampleSchemes) {
        await _firestore.collection('schemes').add(schemeData);
      }
      print('Sample schemes added successfully');
    } catch (e) {
      print('Error adding sample schemes: $e');
    }
  }
}
