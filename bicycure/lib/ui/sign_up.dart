import 'package:flutter/material.dart';
import 'manifest.dart';
import 'package:bicycure/store/bike_data.dart';
import 'package:bicycure/utils/constants.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String? governmentId;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;

  final BikeData bikeData = BikeData(
    rfid_tag: '',
    frame_number: '',
    ownerName: '',
    phoneNumber: '',
    status: '',
  );

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await bikeData.signUp(
          governmentId!,
          firstName!,
          lastName!,
          email!,
          password!,
          phoneNumber!,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('SignUp failed: User already registered'),
          backgroundColor: Colors.red,
        ));
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(color: Colors.black)),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildTextField(
                labelText: 'Government ID',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a valid government ID';
                  }
                  return null;
                },
                onSaved: (value) => governmentId = value,
              ),
              SizedBox(height: 10),
              _buildTextField(
                labelText: 'First Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your first name';
                  }
                  return null;
                },
                onSaved: (value) => firstName = value,
              ),
              SizedBox(height: 10),
              _buildTextField(
                labelText: 'Last Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your last name';
                  }
                  return null;
                },
                onSaved: (value) => lastName = value,
              ),
              SizedBox(height: 10),
              _buildTextField(
                labelText: 'Email',
                validator: (value) {
                  if (value == null ||
                      !RegExp(AppRegex.emailRegex).hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
                onSaved: (value) => email = value,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 10),
              _buildTextField(
                labelText: 'Password',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                onSaved: (value) => password = value,
              ),
              SizedBox(height: 10),
              _buildTextField(
                labelText: 'Phone Number',
                validator: (value) {
                  if (value == null ||
                      !RegExp(AppRegex.phoneNumberPattern).hasMatch(value)) {
                    return 'Enter a valid Dutch phone number (e.g., +31612345678 or 0612345678)';
                  }
                  return null;
                },
                onSaved: (value) => phoneNumber = value,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: validator,
      onSaved: onSaved,
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
