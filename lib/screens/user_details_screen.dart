import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yojana_seva/models/user_data.dart';
import 'package:yojana_seva/providers/auth_provider.dart';
import 'package:yojana_seva/providers/user_provider.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({Key? key}) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
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
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _fatherHusbandNameController.dispose();
    _occupationController.dispose();
    _annualIncomeController.dispose();
    _totalFamilyMembersController.dispose();
    _addressController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final aadhaarNumber = args['aadhaarNumber']!;
    final rationCardNumber = args['rationCardNumber']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                TextFormField(
                  controller: _surnameController,
                  decoration: const InputDecoration(labelText: 'Surname'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your surname' : null,
                ),
                TextFormField(
                  controller: _fatherHusbandNameController,
                  decoration: const InputDecoration(labelText: 'Father/Husband Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the name' : null,
                ),
                 ListTile(
                  title: Text(_dateOfBirth == null
                      ? 'Select Date of Birth'
                      : 'Date of Birth: ${_dateOfBirth!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _religion,
                  decoration: const InputDecoration(labelText: 'Religion'),
                  items: ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Other']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _religion = value;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _caste,
                  decoration: const InputDecoration(labelText: 'Caste'),
                  items: ['OC', 'BC', 'MBC', 'SC', 'ST']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _caste = value;
                    });
                  },
                ),
                TextFormField(
                  controller: _occupationController,
                  decoration: const InputDecoration(labelText: 'Occupation'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your occupation' : null,
                ),
                 TextFormField(
                  controller: _annualIncomeController,
                  decoration: const InputDecoration(labelText: 'Annual Income'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your annual income' : null,
                ),
                TextFormField(
                  controller: _totalFamilyMembersController,
                  decoration: const InputDecoration(labelText: 'Total Family Members'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the number of family members' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                ),
                SwitchListTile(
                  title: const Text('Belong to BPL'),
                  value: _isBpl,
                  onChanged: (value) {
                    setState(() {
                      _isBpl = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Have a Bank Account'),
                  value: _hasBankAccount,
                  onChanged: (value) {
                    setState(() {
                      _hasBankAccount = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final user = authProvider.user!;
                      final userData = UserData(
                        uid: user.uid,
                        aadhaarNumber: aadhaarNumber,
                        rationCardNumber: rationCardNumber,
                        name: _nameController.text,
                        surname: _surnameController.text,
                        fatherHusbandName: _fatherHusbandNameController.text,
                        dateOfBirth: _dateOfBirth!,
                        gender: _gender!,
                        religion: _religion!,
                        caste: _caste!,
                        occupation: _occupationController.text,
                        annualIncome: int.parse(_annualIncomeController.text),
                        totalFamilyMembers:
                            int.parse(_totalFamilyMembersController.text),
                        address: _addressController.text,
                        isBpl: _isBpl,
                        hasBankAccount: _hasBankAccount,
                      );
                      await userProvider.createUser(userData);
                      Navigator.pushNamed(context, '/success');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
