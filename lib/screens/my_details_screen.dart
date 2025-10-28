import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yojana_seva/models/user_data.dart';
import 'package:yojana_seva/providers/auth_provider.dart';
import 'package:yojana_seva/providers/user_provider.dart';

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({Key? key}) : super(key: key);

  @override
  _MyDetailsScreenState createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for editing
  final _nameController = TextEditingController();
  final _fatherHusbandNameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _annualIncomeController = TextEditingController();
  final _totalFamilyMembersController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _religion;
  String? _caste;
  bool _isBpl = false;
  bool _hasBankAccount = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (authProvider.user != null) {
      userProvider.getUser(authProvider.user!.uid).then((_) {
        final userData = userProvider.userData;
        if (userData != null) {
          // Initialize controllers with existing data
          _nameController.text = userData.name;
          _fatherHusbandNameController.text = userData.fatherHusbandName;
          _dateOfBirth = userData.dateOfBirth;
          _gender = userData.gender;
          _religion = userData.religion;
          _caste = userData.caste;
          _occupationController.text = userData.occupation;
          _annualIncomeController.text = userData.annualIncome.toString();
          _totalFamilyMembersController.text =
              userData.totalFamilyMembers.toString();
          _addressController.text = userData.address;
          _isBpl = userData.isBPL;
          _hasBankAccount = userData.hasBankAccount;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherHusbandNameController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    _totalFamilyMembersController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Details'),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteUser(context),
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userData = userProvider.userData;
          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Aadhaar', userData.aadhaarNumber,
                            isEditable: false),
                        _buildInfoRow('Ration Card', userData.rationCardNumber,
                            isEditable: false),
                        _buildEditableInfoRow('Name', _nameController),
                        _buildEditableInfoRow('Father/Husband Name',
                            _fatherHusbandNameController),
                        _buildDateRow('Date of Birth', _dateOfBirth),
                        _buildDropdownRow(
                            'Gender',
                            _gender,
                            ['Male', 'Female', 'Other'],
                            (val) => setState(() => _gender = val)),
                        _buildDropdownRow(
                            'Religion',
                            _religion,
                            ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Other'],
                            (val) => setState(() => _religion = val)),
                        _buildDropdownRow(
                            'Caste',
                            _caste,
                            ['OC', 'BC', 'MBC', 'SC', 'ST'],
                            (val) => setState(() => _caste = val)),
                        _buildEditableInfoRow(
                            'Occupation', _occupationController),
                        _buildEditableInfoRow(
                            'Annual Income', _annualIncomeController,
                            keyboardType: TextInputType.number),
                        _buildEditableInfoRow('Total Family Members',
                            _totalFamilyMembersController,
                            keyboardType: TextInputType.number),
                        _buildEditableInfoRow('Address', _addressController),
                        _buildSwitchTile('BPL', _isBpl,
                            (val) => setState(() => _isBpl = val)),
                        _buildSwitchTile('Bank Account', _hasBankAccount,
                            (val) => setState(() => _hasBankAccount = val)),
                        const SizedBox(height: 24),
                        _buildButtons(context, userData),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableInfoRow(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        enabled: _isEditing,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isEditable = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date) {
    return ListTile(
      title: Text(
          date == null ? 'Select Date' : '${date.toLocal()}'.split(' ')[0]),
      trailing: const Icon(Icons.calendar_today),
      onTap: _isEditing ? () => _selectDate(context) : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Widget _buildDropdownRow(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((label) => DropdownMenuItem(
                child: Text(label),
                value: label,
              ))
          .toList(),
      onChanged: _isEditing ? onChanged : null,
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: _isEditing ? onChanged : null,
      activeColor: const Color(0xFF1E88E5),
    );
  }

  Widget _buildButtons(BuildContext context, UserData userData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        OutlinedButton(
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
          child: Text(_isEditing ? 'Cancel' : 'Edit'),
        ),
        ElevatedButton(
          onPressed: _isEditing ? () => _saveChanges(context, userData) : null,
          child: const Text('Save Changes'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E88E5),
          ),
        ),
      ],
    );
  }

  void _saveChanges(BuildContext context, UserData oldUserData) {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final updatedUserData = UserData(
        aadhaarNumber: oldUserData.aadhaarNumber,
        rationCardNumber: oldUserData.rationCardNumber,
        name: _nameController.text,
        fatherHusbandName: _fatherHusbandNameController.text,
        dateOfBirth: _dateOfBirth!,
        gender: _gender!,
        religion: _religion!,
        caste: _caste!,
        occupation: _occupationController.text,
        annualIncome: double.parse(_annualIncomeController.text),
        totalFamilyMembers: int.parse(_totalFamilyMembersController.text),
        address: _addressController.text,
        isBPL: _isBpl,
        hasBankAccount: _hasBankAccount,
        detailsSubmitted: true,
      );
      userProvider.updateUser(updatedUserData).then((_) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully!')),
        );
      });
    }
  }

  void _deleteUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete your data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                userProvider.deleteUser(authProvider.user!.uid).then((_) {
                  authProvider.signOut();
                  Navigator.of(ctx).pop(); // Close the dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', (Route<dynamic> route) => false);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
