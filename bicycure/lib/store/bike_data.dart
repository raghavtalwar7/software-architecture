import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BikeData {
  String? rfid_tag;
  String? frame_number;
  String? ownerName;
  String? phoneNumber;
  String? status;
  String? brand;
  String? model;
  String? color;
  String? theft_date;
  String? theft_location;
  String? description;
  int? reward_amount;
  int? id;
  int? current_owner_id;
  String? scan_place;
  String? scan_city;
  String? scan_pincode;

  // Constructor to initialize the data
  BikeData({
    this.rfid_tag,
    this.frame_number,
    this.ownerName,
    this.phoneNumber,
    this.status,
    this.brand,
    this.color,
    this.model,
    this.theft_date,
    this.theft_location,
    this.description,
    this.reward_amount,
    this.id,
    this.current_owner_id,
    this.scan_place,
    this.scan_city,
    this.scan_pincode,
  });

  factory BikeData.fromJson(Map<String, dynamic> json) {
    return BikeData(
      rfid_tag: json['rfid_tag'] ?? '',
      frame_number: json['frame_number'] ?? '',
      ownerName: json['ownerName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      status: json['status'] ?? '',
      brand: json['brand'] ?? '',
      color: json['color'] ?? '',
      model: json['model'] ?? '',
      id: json['id'],
      current_owner_id: json['current_owner_id'],
    );
  }

  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<String?> signUp(
    String governmentId,
    String firstName,
    String lastName,
    String email,
    String password,
    String phoneNumber,
  ) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'government_id': governmentId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return responseData['token'];
    } else {
      throw Exception('User already registered');
    }
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_BASE_URL']}/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      await storage.write(
          key: 'token', value: responseData['token']); // Store token securely
      return responseData['token'];
    } else {
      throw Exception('Failed to log in');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token'); // Remove token on logout
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token'); // Retrieve token
  }

  Future<Map<String, String>> getHeaders() async {
    String? token = await getToken();
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json", // or other headers you may need
    };
  }

  // Method to push data to the API
  Future<void> registerBike() async {
    var headers = await getHeaders();
    String apiUrl = '${dotenv.env['API_BASE_URL']}/bicycles';

    // Creating a map of the data
    Map<String, String> data = {
      'rfid_tag': rfid_tag ?? '',
      'frame_number': frame_number ?? '',
      'ownerName': ownerName ?? '',
      'phoneNumber': phoneNumber ?? '',
      'status': status ?? '',
      'brand': brand ?? '',
      'color': color ?? '',
      'model': model ?? '',
    };

    try {
      // Sending a POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        print("Bike registered successfully.");
      } else {
        throw Exception('Error occurred while registering bike');
      }
    } catch (e) {
      throw Exception('Error occurred while registering bike: $e');
    }
  }

  // Method to fetch bike details by rfid_tag
  Future<BikeData?> getBikeData(
      String rfid, String place, String city, String pincode) async {
    var headers = await getHeaders();
    String apiUrl = '${dotenv.env['API_BASE_URL']}/bicycles/scan?rfid=$rfid';

    Map<String, dynamic> requestBody = {
      'rfid': rfid,
      'place': place,
      'city': city,
      'pincode': pincode,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> bikeData = jsonDecode(response.body);

        // Create and return BikeData object from response
        return BikeData(
          rfid_tag: bikeData['rfid_tag'],
          frame_number: bikeData['frame_number'],
          ownerName: bikeData['owner_name'],
          phoneNumber: bikeData['phone_number'],
          status: bikeData['status'],
          brand: bikeData['brand'],
          color: bikeData['color'],
          model: bikeData['model'],
          id: bikeData['id'],
        );
      } else {
        throw Exception("Failed to fetch bike data: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error occurred while fetching bike data: $e");
    }
  }

  Future<List<BikeData>?> getBikeDataForReport() async {
    var headers = await getHeaders();
    String apiUrl = '${dotenv.env['API_BASE_URL']}/bicycles/list';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> bikeListData = jsonDecode(response.body);

        // Map the JSON data to a list of BikeData objects
        List<BikeData> bikeDataList =
            bikeListData.map((bike) => BikeData.fromJson(bike)).toList();

        return bikeDataList;
      } else {
        throw Exception("Failed to fetch bike data: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error occurred while fetching bike data: $e");
    }
  }

  // Method to report a bike as stolen
  Future<void> reportBike() async {
    var headers = await getHeaders();
    String apiUrl = '${dotenv.env['API_BASE_URL']}/theft-reports';

    // Creating a map of the data
    Map<String, dynamic> data = {
      'theft_date': theft_date ?? '',
      'theft_location': theft_location ?? '',
      'description': description ?? '',
      'reward_amount': reward_amount ?? 0,
      'status': 'Stolen',
      'bicycle_id': id ?? 0,
      'reporter_id': current_owner_id ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        print("Bike reported as stolen successfully.");
      } else {
        throw Exception("Failed to report bike: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error occurred while reporting bike: $e");
    }
  }
}
