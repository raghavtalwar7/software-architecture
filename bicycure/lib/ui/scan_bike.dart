import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:bicycure/utils/constants.dart';

import 'package:bicycure/store/bike_data.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nfc_manager/nfc_manager.dart';

class ScanBikeScreen extends StatefulWidget {
  const ScanBikeScreen({super.key});

  @override
  State<ScanBikeScreen> createState() => _ScanBikeScreenState();
}

class _ScanBikeScreenState extends State<ScanBikeScreen> {
  String? rfidError;
  String? scannedRFID; // RFID result after scanning
  bool isScanning = false; // Flag to indicate scanning in progress
  String? ownerName;
  String isStolen = 'Not Stolen'; // Track stolen status
  String? place;
  String? city;
  String? pincode;
  String? currentLocation;

  Future<void> _startScanning() async {
    setState(() {
      isScanning = true;
      scannedRFID = null;
      ownerName = null;
      isStolen = 'Not Stolen';
      place = '';
      city = '';
      pincode = '';
      currentLocation = null;
    });

    try {
      // Start NFC session
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
            String rfid = identifier
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join('')
                .toUpperCase();
            log('${rfid}');
            Position? position = await getCurrentPosition();
            currentLocation = await getAddressFromLatLng(position!);
            setState(() {
              fetchScannedBike(rfid);
              scannedRFID = rfid;
              isScanning = false;
              rfidError = null;
            });
          } catch (e) {
            setState(() {
              isScanning = false;
              rfidError = 'Error extracting RFID: $e';
            });
          } finally {
            await NfcManager.instance.stopSession(); // Stop NFC session
          }
        },
      );
    } catch (e) {
      setState(() {
        isScanning = false;
      });
      print('Error while scanning: $e');
    }
  }

  Future<void> fetchScannedBike(String rfid) async {
    BikeData bikeData = BikeData();

    try {
      var bike = await bikeData.getBikeData(
        rfid,
        place ?? '',
        city ?? '',
        pincode ?? '',
      ); // Fetch bike data based on RFID

      if (bike != null) {
        setState(() {
          ownerName =
              bike.ownerName; // Assuming BikeData has an ownerName property
          isStolen =
              bike.status ?? ''; // Assuming BikeData has an isStolen property
        });
      } else {
        setState(() {
          ownerName = AppStrings.notAvailableText;
          isStolen = 'Not Stolen'; // Default status if bike data not found
        });
      }
    } catch (error) {
      setState(() {
        rfidError = 'Failed to load bike data: $error';
      });
    }
  }

  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled. Please enable the services
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Location permissions are denied
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Location permissions are permanently denied, we cannot request permissions.

      return false;
    }
    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await handleLocationPermission();
      if (!hasPermission) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark address = placeMarks[0];
      place = (address.street ?? '') + " " + (address.subLocality ?? '');
      city = address.subAdministrativeArea;
      pincode = address.postalCode;
      return "${address.street}, ${address.subLocality}, ${address.subAdministrativeArea}, ${address.postalCode}";
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Using constants
      appBar: AppBar(
        title: const Text(
          AppStrings.scanBikeAppBarTitle,
          style: TextStyle(
            color: AppColors.appBarTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appBarBackgroundColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.iconThemeColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              AppStrings.scanInstructionText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: AppDimensions.textFieldFontSize,
                  color: AppColors.instructionTextColor,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (isScanning)
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.scanButtonBackgroundColor),
                  ),
                  SizedBox(height: 10),
                  Text(
                    AppStrings.scanningInProgressText,
                    style: TextStyle(
                        fontSize: AppDimensions.textFieldFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.instructionTextBoldColor),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _startScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.scanButtonBackgroundColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.buttonPaddingVertical,
                      horizontal: AppDimensions.buttonPaddingHorizontal),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                ),
                child: const Text(
                  AppStrings.scanButtonText,
                  style: TextStyle(
                    fontSize: AppDimensions.buttonFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.scanButtonTextColor,
                  ),
                ),
              ),
            const SizedBox(height: 30),
            if (scannedRFID != null) ...[
              const SizedBox(height: 30),
              const Text(
                AppStrings.scannedBikeDetailsTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardBorderRadius),
                  side: BorderSide(
                      color: isStolen.toLowerCase() == 'Stolen'.toLowerCase()
                          ? AppColors.stolenBikeBorderColor
                          : AppColors.nonStolenBikeBorderColor,
                      width: 2),
                ),
                elevation: AppDimensions.cardElevation,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                        BorderRadius.circular(AppDimensions.cardBorderRadius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(AppStrings.rfidLabel, scannedRFID!),
                      const SizedBox(height: 12),
                      _buildDetailRow(AppStrings.ownerNameLabel,
                          ownerName ?? AppStrings.notAvailableText),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                          AppStrings.statusLabel,
                          isStolen.toLowerCase() == 'Stolen'.toLowerCase()
                              ? AppStrings.stolenStatus
                              : AppStrings.notStolenStatus),
                      const SizedBox(height: 12),
                      _buildDetailRow("Last Seen", currentLocation ?? ''),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "$label:",
            style: const TextStyle(
              fontSize: AppDimensions.textFieldFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.detailLabelTextColor,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: AppDimensions.textFieldFontSize,
              fontWeight: FontWeight.w500,
              color: AppColors.detailValueTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
