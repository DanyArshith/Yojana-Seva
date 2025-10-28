import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yojana_seva/providers/scheme_provider.dart';
import 'package:yojana_seva/providers/auth_provider.dart';
import 'package:yojana_seva/models/scheme.dart';
import 'package:yojana_seva/screens/scheme_details_screen.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({Key? key}) : super(key: key);

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  // Track last inputs to avoid redundant filtering
  int _lastAllSchemesCount = -1;
  String _lastUserSignature = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureSchemesThenFilter();
    });
  }

  Future<void> _ensureSchemesThenFilter() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final schemeProvider = Provider.of<SchemeProvider>(context, listen: false);

    if (schemeProvider.allSchemes.isEmpty) {
      await schemeProvider.loadSchemes();
    }
    await schemeProvider.loadPersonalizedSchemes(authProvider.userData);
    // Ensure filtered schemes are set to personalized schemes
    schemeProvider.resetSearch();
    _rememberSignature(authProvider, schemeProvider);
  }

  void _rememberSignature(
      AuthProvider authProvider, SchemeProvider schemeProvider) {
    _lastAllSchemesCount = schemeProvider.allSchemes.length;
    final u = authProvider.userData;
    _lastUserSignature = u == null
        ? 'null'
        : '${u.gender}|${u.age}|${u.rationCardNumber.isNotEmpty}|${u.detailsSubmitted}';
  }

  bool _signatureChanged(
      AuthProvider authProvider, SchemeProvider schemeProvider) {
    if (_lastAllSchemesCount != schemeProvider.allSchemes.length) return true;
    final u = authProvider.userData;
    final sig = u == null
        ? 'null'
        : '${u.gender}|${u.age}|${u.rationCardNumber.isNotEmpty}|${u.detailsSubmitted}';
    return sig != _lastUserSignature;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-filter when navigating back to this tab if inputs changed
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final schemeProvider =
          Provider.of<SchemeProvider>(context, listen: false);
      if (_signatureChanged(authProvider, schemeProvider)) {
        await _ensureSchemesThenFilter();
      }
    });
  }

  // Helper: checks if user satisfies all constraints for a scheme
  bool _isUserEligibleForScheme(Scheme scheme, userData) {
    if (userData == null) return false;
    // Age constraint
    if (scheme.ageRange != null) {
      final ageParts = scheme.ageRange.split('-');
      if (ageParts.length == 2) {
        final minAge = int.tryParse(ageParts[0].trim()) ?? 0;
        final maxAge = int.tryParse(ageParts[1].trim()) ?? 200;
        if (userData.age < minAge || userData.age > maxAge) return false;
      }
    }
    // Gender constraint
    if (scheme.gender != null &&
        scheme.gender.isNotEmpty &&
        scheme.gender != 'Any') {
      if (userData.gender != scheme.gender) return false;
    }
    // Ration card constraint
    if (scheme.requiresRationCard == true) {
      if (userData.rationCardNumber == null ||
          userData.rationCardNumber.isEmpty) return false;
    }
    // ...add more constraints here if needed...
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    // Responsive padding
    final horizontalPadding =
        isSmallScreen ? 16.0 : (isMediumScreen ? 24.0 : 32.0);
    final verticalPadding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // App Bar - Full Width
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schemes for You',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    'Personalized recommendations based on your profile',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Consumer2<AuthProvider, SchemeProvider>(
                builder: (context, authProvider, schemeProvider, child) {
                  // Check if user is logged in
                  if (authProvider.user == null) {
                    return _buildNotLoggedInState(isSmallScreen);
                  }

                  // Check if user has submitted details
                  if (authProvider.userData == null ||
                      !authProvider.userData!.detailsSubmitted) {
                    return _buildNoProfileState(isSmallScreen);
                  }

                  // Show loading state
                  if (schemeProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                      ),
                    );
                  }

                  // Show personalized schemes (filtered by eligibility)
                  final userData = authProvider.userData;
                  final eligibleSchemes = schemeProvider.filteredSchemes
                      .where((scheme) =>
                          _isUserEligibleForScheme(scheme, userData))
                      .toList();

                  if (eligibleSchemes.isEmpty) {
                    return _buildNoSchemesState(isSmallScreen);
                  }

                  // Responsive grid/list layout
                  if (screenWidth >= 900) {
                    // Large screens - 2 column grid
                    return GridView.builder(
                      padding: EdgeInsets.all(horizontalPadding),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.5,
                      ),
                      itemCount: eligibleSchemes.length,
                      itemBuilder: (context, index) {
                        final scheme = eligibleSchemes[index];
                        return _buildSchemeCard(scheme, isSmallScreen);
                      },
                    );
                  } else {
                    // Small/Medium screens - single column list
                    return ListView.builder(
                      padding: EdgeInsets.all(horizontalPadding),
                      itemCount: eligibleSchemes.length,
                      itemBuilder: (context, index) {
                        final scheme = eligibleSchemes[index];
                        return _buildSchemeCard(scheme, isSmallScreen);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInState(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: isSmallScreen ? 56 : 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Please log in to see personalized schemes',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'Sign in to get recommendations based on your profile',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoProfileState(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add,
                size: isSmallScreen ? 56 : 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'Complete your profile',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 32.0,
                ),
                child: Text(
                  'Add your details to see personalized scheme recommendations',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
              ElevatedButton(
                onPressed: () {
                  // Navigate to profile tab - this will be handled by parent
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Please go to the Profile tab to complete your details'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 24 : 32,
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Complete Profile',
                  style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSchemesState(bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: isSmallScreen ? 56 : 64,
                color: Colors.grey[400],
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Text(
                'No schemes available for your profile',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16.0 : 32.0,
                ),
                child: Text(
                  'We couldn\'t find any schemes that match your current profile. Try updating your details or check back later.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(Scheme scheme, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SchemeDetailsScreen(scheme: scheme),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isSmallScreen ? 44 : 50,
                      height: isSmallScreen ? 44 : 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(isSmallScreen ? 10 : 12),
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: const Color(0xFFE91E63),
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scheme.name,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF212121),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 3 : 4),
                          Text(
                            scheme.description,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: isSmallScreen ? 14 : 16,
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Wrap(
                  spacing: isSmallScreen ? 6 : 8,
                  runSpacing: isSmallScreen ? 6 : 8,
                  children: [
                    if (scheme.ageRange != null && scheme.ageRange!.isNotEmpty)
                      _buildEligibilityChip(
                        'Age: ${scheme.ageRange}',
                        const Color(0xFF4CAF50),
                        isSmallScreen,
                      ),
                    if (scheme.gender != null && scheme.gender!.isNotEmpty)
                      _buildEligibilityChip(
                        scheme.gender!,
                        const Color(0xFF2196F3),
                        isSmallScreen,
                      ),
                    if (scheme.requiresRationCard == true)
                      _buildEligibilityChip(
                        'Ration Card Required',
                        const Color(0xFFFF9800),
                        isSmallScreen,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEligibilityChip(String label, Color color, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 6 : 8,
        vertical: isSmallScreen ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmallScreen ? 11 : 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
