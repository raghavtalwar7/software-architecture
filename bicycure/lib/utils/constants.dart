import 'package:flutter/material.dart';

class AppStrings {
  // Register Bike screen strings
  static const String registerBikeTitle = "Register a Bike";
  static const String bikeDetailsTitle = "Bike Details";
  static const String rfidLabel = "RFID";
  static const String rfidHint = "Enter RFID tag number";
  static const String frameNumberLabel = "Frame Number";
  static const String frameNumberHint = "Enter bike's frame number";
  static const String ownerNameLabel = "Owner Name";
  static const String ownerNameHint = "Enter owner's name";
  static const String phoneNumberLabel = "Phone Number (NL)";
  static const String phoneNumberHint = "Enter your phone number";
  static const String brandLabel = 'Brand';
  static const String brandHint = 'Enter bike brand';
  static const String modelLabel = 'Model';
  static const String modelHint = 'Enter bike model';
  static const String colorLabel = 'Color';
  static const String colorHint = 'Enter bike color';
  static const String registerButton = "Register Bike";
  static const String rfidError = "RFID is required.";
  static const String frameNumberError = "Frame Number is required.";
  static const String ownerNameError = "Owner Name is required.";
  static const String phoneNumberRequiredError = "Phone number is required.";
  static const String brandError = "Brand is required.";
  static const String modelError = "Model is required.";
  static const String colorError = "Color of bike is required.";
  static const String invalidPhoneNumberError = "Invalid phone number.";
  static const String registrationSuccessMessage = "Bike registered successfully!";
  static const String registrationFailureMessage = "Failed to register the bike. Bike already registered.";

  // ScanBikeScreen strings
  static const String scanBikeAppBarTitle = "Scan a Bike";
  static const String scanInstructionText =
      "Tap the button below to start scanning the bike's RFID tag.";
  static const String scanningInProgressText = "Scanning in progress...";
  static const String scanButtonText = "Scan Bike";
  static const String scannedBikeDetailsTitle = "Scanned Bike Details:";
  static const String lastSeenLocation = "Location XYZ";
  static const String notAvailableText = "N/A";

  // RFID & owner detail labels
  static const String statusLabel = "Status";
  static const String notStolenStatus = "Not Stolen";
  static const String stolenStatus = "Stolen";

  // Report Bike screen strings
  static const String reportStolenBikeTitle = 'Report Stolen Bike';
  static const String reportStolenBikeSubtitle = 'Report a bike as stolen';
  static const String selectBikeInstruction = 'Select the bike to report as stolen:';
  static const String selectBikeHint = 'Select a bike';
  static const String selectBikeError = 'Please select a bike.';
  static const String bikeReportedAsStolen = 'The bike has been reported as stolen.';
  static const String reportBikeError = 'Error reporting bike.';
  static const String reportButtonText = 'Report Stolen';
}

class AppColors {
  static const Color primaryColor = Colors.green;
  static const Color secondaryColor = Colors.greenAccent;
  static const Color errorColor = Colors.red;
  static const Color textColor = Colors.black;
  static const Color hintColor = Colors.grey;
  static const Color inputBorderColor = Colors.grey;
  static const Color focusedBorderColor = Colors.green;
  static const Color subTextColor = Colors.black54;

  // ScanBikeScreen colors
  static const Color appBarBackgroundColor = Colors.white;
  static const Color appBarTextColor = Colors.black;
  static const Color iconThemeColor = Colors.black;
  static const Color instructionTextColor = Colors.black;
  static const Color instructionTextBoldColor = Colors.black87;
  static const Color scanButtonBackgroundColor = Colors.orange;
  static const Color scanButtonTextColor = Colors.white;
  static const Color stolenBikeBorderColor = Colors.red;
  static const Color nonStolenBikeBorderColor = Colors.green;
  static const Color detailLabelTextColor = Colors.black54;
  static const Color detailValueTextColor = Colors.black87;

  // ReportBikeScreen colors
  static const Color reportButtonBackgroundColor = Colors.redAccent;
  static const Color reportButtonTextColor = Colors.white;
}

class AppDimensions {
  static const double textFieldFontSize = 16.0;
  static const double borderRadius = 10.0;
  static const double paddingLarge = 20.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall = 8.0;
  static const double buttonFontSize = 16.0;
  static const double buttonPaddingVertical = 14.0;
  static const double buttonPaddingHorizontal = 60.0;

  // ScanBikeScreen dimensions
  static const double circularProgressSize = 16.0;
  static const double cardElevation = 4.0;
  static const double cardBorderRadius = 16.0;

  // ReportBikeScreen dimensions
  static const double reportButtonPaddingVertical = 16.0;
  static const double reportButtonPaddingHorizontal = 36.0;
}

class AppRegex {
  static const String phoneNumberPattern = r'^(?:\+31|0)[1-9]\d{8}$';
  static const emailRegex = r'^[^@]+@[^@]+\.[^@]+';
  static const dateRegex = r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$';
}