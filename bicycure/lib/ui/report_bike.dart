import 'package:bicycure/store/bike_data.dart';
import 'package:flutter/material.dart';
import 'package:bicycure/utils/constants.dart';

class ReportBikeScreen extends StatefulWidget {
  const ReportBikeScreen({super.key});

  @override
  State<ReportBikeScreen> createState() => _ReportBikeScreenState();
}

class _ReportBikeScreenState extends State<ReportBikeScreen> {
  BikeData? selectedBike;
  late Future<List<BikeData>?> _registeredBikesFuture;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _theftDateController = TextEditingController();
  final TextEditingController _theftLocationController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _registeredBikesFuture = _fetchRegisteredBikes();
  }

  Future<List<BikeData>?> _fetchRegisteredBikes() async {
    BikeData bikeData = BikeData();

    try {
      return await bikeData.getBikeDataForReport();
    } catch (error) {
      throw Exception('Failed to load bikes: No bikes registered by you');
    }
  }

  void _reportStolenBike() async {
    final int rewardAmount = int.parse(_rewardAmountController.text);

    BikeData bikeData = BikeData(
      rfid_tag: selectedBike!.rfid_tag,
      frame_number: selectedBike!.frame_number,
      ownerName: selectedBike!.ownerName,
      phoneNumber: selectedBike!.phoneNumber,
      brand: selectedBike!.brand,
      model: selectedBike!.model,
      color: selectedBike!.color,
      status: 'Stolen',
      theft_date: _theftDateController.text,
      theft_location: _theftLocationController.text,
      description: _descriptionController.text,
      reward_amount: rewardAmount,
      id: selectedBike?.id ?? 0,
      current_owner_id: selectedBike?.current_owner_id ?? 0,
    );

    if (_formKey.currentState?.validate() ?? false) {
      if (selectedBike == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.selectBikeError)),
        );
        return;
      }

      try {
        await bikeData.reportBike();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.bikeReportedAsStolen)),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.reportBikeError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          AppStrings.reportStolenBikeTitle,
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
        child: FutureBuilder<List<BikeData>?>(
          future: _registeredBikesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No registered bikes found.'));
            }

            List<BikeData> registeredBikes = snapshot.data!;

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    AppStrings.reportStolenBikeSubtitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingMedium),
                  const Text(
                    AppStrings.selectBikeInstruction,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingSmall),

                  // Dropdown to select a bike
                  DropdownButton<BikeData>(
                    value: selectedBike,
                    hint: const Text(AppStrings.selectBikeHint),
                    isExpanded: true,
                    items: registeredBikes.map((bike) {
                      return DropdownMenuItem<BikeData>(
                        value: bike,
                        child: Text(
                          '${bike.brand} ${bike.model} - ${bike.color}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                    onChanged: (bike) {
                      setState(() {
                        selectedBike = bike;
                      });
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Theft Date input field
                  TextFormField(
                    controller: _theftDateController,
                    decoration: const InputDecoration(
                      labelText: 'Theft Date',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the theft date.';
                      }
                      if (!RegExp(AppRegex.dateRegex).hasMatch(value)) {
                        return 'Please enter a valid date (yyyy-mm-dd).';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Theft Location input field
                  TextFormField(
                    controller: _theftLocationController,
                    decoration: const InputDecoration(
                      labelText: 'Theft Location',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the theft location.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Description input field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingMedium),

                  // Reward Amount input field
                  TextFormField(
                    controller: _rewardAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Reward Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a reward amount.';
                      }
                      // Check if the input can be parsed as an integer
                      final int? amount = int.tryParse(value);
                      if (amount == null || amount < 0) {
                        return 'Please enter a valid positive integer.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingLarge),

                  // Report button
                  Center(
                    child: ElevatedButton(
                      onPressed: _reportStolenBike,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.reportButtonBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimensions.buttonPaddingVertical,
                          horizontal: AppDimensions.buttonPaddingHorizontal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.borderRadius),
                        ),
                      ),
                      child: const Text(
                        AppStrings.reportButtonText,
                        style: TextStyle(
                          fontSize: AppDimensions.buttonFontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.reportButtonTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
