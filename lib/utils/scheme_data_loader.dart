import 'package:cloud_firestore/cloud_firestore.dart';

class SchemeDataLoader {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> addSampleSchemes() async {
    final List<Map<String, dynamic>> sampleSchemes = [
      {
        "id": "sampoorna_poshana_plus",
        "name": "Sampoorna Poshana Plus",
        "ageRange": "0-6",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Nutrition and health support for children aged 0-6 and pregnant/lactating mothers to improve health outcomes.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "thalliki_vandanam",
        "name": "Thalliki Vandanam",
        "ageRange": "0-6",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Financial incentive to mothers of children (0-6 yrs) for early childhood care and development support.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "cheyutha",
        "name": "Cheyutha",
        "ageRange": "45-60",
        "gender": "Female",
        "requiresRationCard": true,
        "description":
            "Scheme targeted at women aged 45-60 with ration card to provide financial assistance for livelihood enhancement.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "kapu_nestham",
        "name": "Kapu Nestham",
        "ageRange": "45-60",
        "gender": "Female",
        "requiresRationCard": true,
        "description":
            "Support for women aged between 45 and 60 from Kapu community (with ration card) to bolster social/welfare benefits.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "pension_kanuka",
        "name": "Pension Kanuka",
        "ageRange": "60+",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Old‐age pension scheme for citizens aged 60 or above, subject to holding a ration card.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "nirudyoga_bruthi",
        "name": "Nirudyoga Bruthi",
        "ageRange": "22-35",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Unemployment allowance for youth between 22 and 35 who hold a ration card and meet eligibility criteria.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "vidyonnathi_scheme",
        "name": "Vidyonnathi Scheme",
        "ageRange": "22-35",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Educational support scheme for youth aged 22-35 holding a ration card — coaching, skill development & higher education assistance.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "ammavodi_scheme",
        "name": "Ammavodi Scheme",
        "ageRange": "3-17",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Educational support for children aged 3-17 whose families hold a ration card; aims to ensure school enrolment and attendance.",
        "link": "https://<official-link-placeholder>"
      },
      {
        "id": "fee_reimbursement_scheme",
        "name": "Fee Reimbursement Scheme",
        "ageRange": "18-21",
        "gender": "Any",
        "requiresRationCard": true,
        "description":
            "Provides reimbursement of tuition/fees for students aged 18-21 with a ration card in order to promote higher education access.",
        "link": "https://<official-link-placeholder>"
      }
    ];

    try {
      // Upsert each scheme into schemes/{id} without overwriting existing docs
      for (final scheme in sampleSchemes) {
        final String id = scheme['id'] as String;
        final data = Map<String, dynamic>.from(scheme)..remove('id');
        final docRef = _firestore.collection('schemes').doc(id);
        final snapshot = await docRef.get();
        if (!snapshot.exists) {
          await docRef.set(data);
        }
      }
    } catch (e) {
      print('Error adding sample schemes: $e');
    }
  }
}
