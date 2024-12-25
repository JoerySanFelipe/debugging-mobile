import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http; // Correct import statement
import 'address_info.dart'; // Import the AddressInfo class

// Define the starting coordinates as constants
const double shopLatitude = 15.9757;
const double shopLongitude = 120.5660;

// Function to convert degrees to radians
double _toRadians(double degrees) {
  return degrees * pi / 180;
}

// Haversine formula to calculate the distance between two points on the Earth
double calculateDistance(double lat1, double lon1, double lat2, double lon2, String customerAddress) {
  const double R = 6371; // Earth's radius in kilometers
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = R * c;

  double roundedDistance = distance.roundToDouble();

  // Update AddressInfo with calculated values
  AddressInfo.customerAddress = customerAddress;
  AddressInfo.addressLatitude = lat2; // Store the customer's latitude
  AddressInfo.addressLongitude = lon2; // Store the customer's longitude
  AddressInfo.addressDistance = roundedDistance; // Store the rounded distance
  AddressInfo.addressDistanceFee = multiplyDistance(roundedDistance); // Calculate and store distance fee

  return roundedDistance; // Return the rounded distance for further use
}

// Function to multiply the distance by 12
double multiplyDistance(double distance) {
  double multipliedDistance = distance * 12;
  return multipliedDistance;
}

// Function to convert an address to latitude and longitude using a geocoding service
Future<List<double>?> convertAddressToLatLng(String address) async {
  final String url = 'https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        double latitude = double.parse(data[0]['lat']);
        double longitude = double.parse(data[0]['lon']);
        print('Latitude: $latitude, Longitude: $longitude');
        return [latitude, longitude];
      }
    }
    print('Failed to fetch data');
  } catch (e) {
    print('Error: $e');
  }
  return null;
}
