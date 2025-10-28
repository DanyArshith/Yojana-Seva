import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yojana_seva/providers/auth_provider.dart';
import 'package:yojana_seva/models/user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _rationCardController = TextEditingController();
  final _nameController = TextEditingController();
  final _fatherHusbandController = TextEditingController();
  final _genderController = TextEditingController();
  final _religionController = TextEditingController();
  final _casteController = TextEditingController();
  final _occupationController = TextEditingController();
  final _annualIncomeController = TextEditingController();
  final _familyMembersController = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedDate;
  bool _isBPL = false;
  bool _hasBankAccount = false;
  bool _isEditing = true; // Start in editing mode for new users
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _religionOptions = [
    'Hindu',
    'Muslim',
    'Christian',
    'Sikh',
    'Buddhist',
    'Jain',
    'Other'
  ];
  final List<String> _casteOptions = ['General', 'OBC', 'SC', 'ST', 'Other'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _rationCardController.dispose();
    _nameController.dispose();
    _fatherHusbandController.dispose();
    _genderController.dispose();
    _religionController.dispose();
    _casteController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    _familyMembersController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = authProvider.userData;

    if (userData != null && userData.detailsSubmitted) {
      _aadhaarController.text = userData.aadhaarNumber;
      _rationCardController.text = userData.rationCardNumber;
      _nameController.text = userData.name;
      _fatherHusbandController.text = userData.fatherHusbandName;
      _selectedDate = userData.dateOfBirth;
      _genderController.text = userData.gender;
      _religionController.text = userData.religion;
      _casteController.text = userData.caste;
      _occupationController.text = userData.occupation;
      _annualIncomeController.text = userData.annualIncome.toString();
      _familyMembersController.text = userData.totalFamilyMembers.toString();
      _addressController.text = userData.address;
      _isBPL = userData.isBPL;
      _hasBankAccount = userData.hasBankAccount;
      _isEditing = false; // Set to read-only mode for existing users
    } else {
      _isEditing = true; // Set to editing mode for new users
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.user == null) {
              return _buildNotLoggedInState();
            }

            return Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      const Spacer(),
                      if (authProvider.userData?.detailsSubmitted == true)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          },
                          icon: Icon(
                            _isEditing ? Icons.close : Icons.edit,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                    ],
                  ),
                ),

                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildProfileCard(authProvider),
                          const SizedBox(height: 24),
                          _buildPersonalDetailsCard(),
                          const SizedBox(height: 24),
                          _buildEligibilityCard(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Please log in to view your profile',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to access your profile and personalized features',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF1E88E5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            authProvider.user?.displayName ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: authProvider.userData?.detailsSubmitted == true
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              authProvider.userData?.detailsSubmitted == true
                  ? 'Profile Complete'
                  : 'Profile Incomplete',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: authProvider.userData?.detailsSubmitted == true
                    ? Colors.green[700]
                    : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _aadhaarController,
            label: 'Aadhaar Number',
            hint: 'Enter 12-digit Aadhaar number',
            keyboardType: TextInputType.number,
            maxLength: 12,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Aadhaar number';
              }
              if (value.length != 12) {
                return 'Aadhaar number must be 12 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _rationCardController,
            label: 'Ration Card Number',
            hint: 'Enter ration card number',
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter ration card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _fatherHusbandController,
            label: 'Father/Husband Name',
            hint: 'Enter father or husband name',
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter father/husband name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildDropdownField(
            controller: _genderController,
            label: 'Gender',
            options: _genderOptions,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select gender';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            controller: _religionController,
            label: 'Religion',
            options: _religionOptions,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select religion';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            controller: _casteController,
            label: 'Caste',
            options: _casteOptions,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select caste';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _occupationController,
            label: 'Occupation',
            hint: 'Enter your occupation',
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your occupation';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _annualIncomeController,
            label: 'Annual Income',
            hint: 'Enter annual income in ₹',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter annual income';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _familyMembersController,
            label: 'Total Family Members',
            hint: 'Enter number of family members',
            keyboardType: TextInputType.number,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter number of family members';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter your complete address',
            maxLines: 3,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildSwitchTile(
            title: 'Below Poverty Line (BPL)',
            value: _isBPL,
            onChanged: _isEditing
                ? (value) {
                    setState(() {
                      _isBPL = value;
                    });
                  }
                : null,
          ),
          _buildSwitchTile(
            title: 'Has Bank Account',
            value: _hasBankAccount,
            onChanged: _isEditing
                ? (value) {
                    setState(() {
                      _hasBankAccount = value;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.userData?.detailsSubmitted == true && !_isEditing) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      authProvider.userData?.detailsSubmitted == true
                          ? 'Update Details'
                          : 'Save Details',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            if (authProvider.userData?.detailsSubmitted == true)
              const SizedBox(height: 12),
            if (authProvider.userData?.detailsSubmitted == true)
              OutlinedButton(
                onPressed: _isLoading ? null : _handleCancel,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF1E88E5)),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: enabled ? Colors.grey[300]! : Colors.grey[200]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required List<String> options,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: enabled ? Colors.grey[300]! : Colors.grey[200]!),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      items: options.map((String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
      onChanged: enabled
          ? (String? value) {
              if (value != null) {
                setState(() {
                  controller.text = value;
                });
              }
            }
          : null,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _isEditing ? _selectDate : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          hintText: _selectedDate == null ? 'Select date of birth' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: _isEditing ? Colors.grey[300]! : Colors.grey[200]!),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          filled: !_isEditing,
          fillColor: _isEditing ? null : Colors.grey[100],
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          _selectedDate == null
              ? 'Select date of birth'
              : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
          style: TextStyle(
            color: _selectedDate == null ? Colors.grey[500] : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1E88E5),
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = UserData(
        aadhaarNumber: _aadhaarController.text.trim(),
        rationCardNumber: _rationCardController.text.trim(),
        name: _nameController.text.trim(),
        fatherHusbandName: _fatherHusbandController.text.trim(),
        dateOfBirth: _selectedDate!,
        gender: _genderController.text,
        religion: _religionController.text,
        caste: _casteController.text,
        occupation: _occupationController.text.trim(),
        annualIncome: double.parse(_annualIncomeController.text),
        totalFamilyMembers: int.parse(_familyMembersController.text),
        address: _addressController.text.trim(),
        isBPL: _isBPL,
        hasBankAccount: _hasBankAccount,
        detailsSubmitted: true,
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.saveUserData(userData);

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.userData?.detailsSubmitted == true
                  ? 'Profile updated successfully!'
                  : 'Profile saved successfully!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleCancel() {
    setState(() {
      _isEditing = false;
    });
    _loadUserData();
  }
}
