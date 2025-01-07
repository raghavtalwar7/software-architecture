import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:bicycure/store/bike_data.dart';
import 'package:bicycure/utils/constants.dart';
import 'package:nfc_manager/nfc_manager.dart';

class RegisterBikeScreen extends StatefulWidget {
  const RegisterBikeScreen({super.key});

  @override
  State<RegisterBikeScreen> createState() => _RegisterBikeScreenState();
}

class _RegisterBikeScreenState extends State<RegisterBikeScreen> {
  final TextEditingController rfidController = TextEditingController();
  final TextEditingController frameNumberController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  String? _errorMessage;
  String? _rfidError,
      _frameNumberError,
      _ownerNameError,
      _brandError,
      _modelError,
      _colorError;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    rfidController.addListener(() {
      setState(() {
        _rfidError = rfidController.text.isEmpty ? AppStrings.rfidError : null;
      });
    });

    frameNumberController.addListener(() {
      setState(() {
        _frameNumberError = frameNumberController.text.isEmpty
            ? AppStrings.frameNumberError
            : null;
      });
    });

    ownerNameController.addListener(() {
      setState(() {
        _ownerNameError =
            ownerNameController.text.isEmpty ? AppStrings.ownerNameError : null;
      });
    });

    brandController.addListener(() {
      setState(() {
        _brandError =
            brandController.text.isEmpty ? AppStrings.brandError : null;
      });
    });

    modelController.addListener(() {
      setState(() {
        _modelError =
            modelController.text.isEmpty ? AppStrings.modelError : null;
      });
    });

    colorController.addListener(() {
      setState(() {
        _colorError =
            colorController.text.isEmpty ? AppStrings.colorError : null;
      });
    });

    phoneNumberController.addListener(() {
      setState(() {
        String phoneNumber = phoneNumberController.text;
        if (phoneNumber.isEmpty) {
          _errorMessage = AppStrings.phoneNumberRequiredError;
        } else if (!_validatePhoneNumber(phoneNumber)) {
          _errorMessage = AppStrings.invalidPhoneNumberError;
        } else {
          _errorMessage = null; // Clear error if valid
        }
      });
    });
  }

  @override
  void dispose() {
    rfidController.dispose();
    frameNumberController.dispose();
    ownerNameController.dispose();
    phoneNumberController.dispose();
    brandController.dispose();
    modelController.dispose();
    colorController.dispose();
    super.dispose();
  }

  Future<void> _startScanning() async {
    setState(() {
      isScanning = true;
      rfidController.clear();
      _rfidError = null;
    });

    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        throw Exception('NFC is not available on this device.');
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Log the full tag data for debugging
            log('NFC Tag data: ${tag.data.toString()}');

            // Extract the identifier (common across isodep, nfca, and ndefformatable)
            List<int> identifier = tag.data['isodep']['identifier'] ??
                tag.data['nfca']['identifier'] ??
                tag.data['ndefformatable']['identifier'];

            // Convert identifier to a hexadecimal string
            String rfid = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
            log('${rfid}');
            setState(() {
              rfidController.text = rfid; // Display the RFID in the controller
              isScanning = false;
              _rfidError = null;
            });
          } catch (e) {
            setState(() {
              isScanning = false;
              _rfidError = 'Error extracting RFID: $e';
            });
          } finally {
            await NfcManager.instance.stopSession(); // Stop NFC session
          }
        },
      );
    } catch (e) {
      setState(() {
        isScanning = false;
        _rfidError = 'Failed to scan RFID: $e';
      });
    }
  }



  void _submitBikeData() async {
    String rfid = rfidController.text;
    String frameNumber = frameNumberController.text;
    String ownerName = ownerNameController.text;
    String phoneNumber = phoneNumberController.text;
    String brand = brandController.text;
    String model = modelController.text;
    String color = colorController.text;

    // Reset error messages
    _rfidError = _frameNumberError = _ownerNameError =
        _errorMessage = _brandError = _modelError = _colorError = null;

    // Validate inputs
    bool hasErrors = false;

    if (rfid.isEmpty) {
      setState(() {
        _rfidError = AppStrings.rfidError;
      });
      hasErrors = true;
    }

    if (frameNumber.isEmpty) {
      setState(() {
        _frameNumberError = AppStrings.frameNumberError;
      });
      hasErrors = true;
    }

    if (ownerName.isEmpty) {
      setState(() {
        _ownerNameError = AppStrings.ownerNameError;
      });
      hasErrors = true;
    }

    // Validate phone number (already done in listener, but we can do another check here)
    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = AppStrings.phoneNumberRequiredError;
      });
      hasErrors = true;
    } else if (!_validatePhoneNumber(phoneNumber)) {
      setState(() {
        _errorMessage = AppStrings.invalidPhoneNumberError;
      });
      hasErrors = true;
    }

    if (brand.isEmpty) {
      setState(() {
        _brandError = AppStrings.brandError;
      });
      hasErrors = true;
    }

    if (model.isEmpty) {
      setState(() {
        _modelError = AppStrings.modelError;
      });
      hasErrors = true;
    }

    if (color.isEmpty) {
      setState(() {
        _colorError = AppStrings.colorError;
      });
      hasErrors = true;
    }

    // If there are any errors, return early and don't submit the form
    if (hasErrors) {
      return;
    }

    // If no errors, proceed with API submission
    BikeData bikeData = BikeData(
      rfid_tag: rfid,
      frame_number: frameNumber,
      ownerName: ownerName,
      phoneNumber: phoneNumber,
      brand: brand,
      model: model,
      color: color,
      status: '',
    );

    try {
      await bikeData.registerBike();
      _showSnackBar(
          AppStrings.registrationSuccessMessage); // Show success message
      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog(
          AppStrings.registrationFailureMessage); // Show error dialog
    }
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Registration Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _validatePhoneNumber(String phoneNumber) {
    // Regex for validating Dutch phone numbers
    final regex = RegExp(AppRegex.phoneNumberPattern);
    return regex.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          AppStrings.registerBikeTitle,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(AppStrings.bikeDetailsTitle),
            const SizedBox(height: AppDimensions.paddingLarge),
            _buildRfidInputField(),
            // RFID field that is uneditable but can scan
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildInputField(
              controller: frameNumberController,
              label: AppStrings.frameNumberLabel,
              hintText: AppStrings.frameNumberHint,
              errorMessage: _frameNumberError,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildInputField(
              controller: ownerNameController,
              label: AppStrings.ownerNameLabel,
              hintText: AppStrings.ownerNameHint,
              errorMessage: _ownerNameError,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildInputField(
              controller: phoneNumberController,
              label: AppStrings.phoneNumberLabel,
              hintText: AppStrings.phoneNumberHint,
              isPhoneNumber: true,
              errorMessage: _errorMessage,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            _buildInputField(
              controller: brandController,
              label: AppStrings.brandLabel,
              hintText: AppStrings.brandHint,
              errorMessage: _brandError,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
// Model field
            _buildInputField(
              controller: modelController,
              label: AppStrings.modelLabel,
              hintText: AppStrings.modelHint,
              errorMessage: _modelError,
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
// Color field
            _buildInputField(
              controller: colorController,
              label: AppStrings.colorLabel,
              hintText: AppStrings.colorHint,
              errorMessage: _colorError,
            ),
            const SizedBox(height: AppDimensions.paddingLarge),
            Align(
              alignment: Alignment.center,
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor.withOpacity(0.6),
      ),
    );
  }

  Widget _buildRfidInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: rfidController,
          style: const TextStyle(fontSize: AppDimensions.textFieldFontSize),
          decoration: InputDecoration(
            labelText: AppStrings.rfidLabel,
            hintText: AppStrings.rfidHint,
            filled: true,
            enabled: false,
            // Set the field as uneditable
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: const BorderSide(color: AppColors.inputBorderColor),
            ),
            errorText: _rfidError, // Show error only if RFID is not scanned
          ),
        ),
        const SizedBox(height: AppDimensions.paddingMedium),
        ElevatedButton(
          onPressed: _startScanning,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.buttonPaddingVertical,
              horizontal: AppDimensions.buttonPaddingHorizontal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            elevation: 2,
          ),
          child: isScanning
              ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : const Text(
                  AppStrings.scanButtonText,
                  style: TextStyle(
                    fontSize: AppDimensions.buttonFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool isPhoneNumber = false,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: AppDimensions.textFieldFontSize),
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            filled: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              borderSide: const BorderSide(
                  color: AppColors.inputBorderColor), // Border color
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: AppColors.focusedBorderColor, width: 1.5),
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            errorText: errorMessage, // Show error message if invalid
          ),
          keyboardType:
              isPhoneNumber ? TextInputType.phone : TextInputType.text,
        ),
        if (isPhoneNumber) const SizedBox(height: AppDimensions.paddingSmall),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitBikeData,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.buttonPaddingVertical,
          horizontal: AppDimensions.buttonPaddingHorizontal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        elevation: 2,
      ),
      child: const Text(
        AppStrings.registerButton,
        style: TextStyle(
          fontSize: AppDimensions.buttonFontSize,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
