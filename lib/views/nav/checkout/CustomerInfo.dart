import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../models/Address.dart';
import '../../../models/transaction/TransactionType.dart';
import '../../../models/users/Customer.dart';
import 'package:agritechv2/models/distance_utils.dart'; // Import the distance utility functions
import '../../../utils/Constants.dart';

class CustomerInfo extends StatelessWidget {
  final Customer? customer;
  final TransactionType type;

  CustomerInfo({
    required this.customer,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            type == TransactionType.DELIVERY
                ? "Shipping Details"
                : "Pick up Details",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Image.asset("lib/assets/images/from.png"),
                title: Text(
                  type == TransactionType.DELIVERY ? "From" : "Pick up from",
                  style: TextStyle(color: Colors.grey[400]),
                ),
                subtitle: const Text(
                  "Belmonte St., 2428 Urdaneta, Pangasinan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14),
                ),
              ),
              if (type == TransactionType.DELIVERY) ...[
                const Divider(color: Colors.grey, height: 10),
                ListTile(
                  enabled: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Image.asset("lib/assets/images/loc.png"),
                  title: const Text("To"),
                  subtitle: displayAddress(context, customer),
                  trailing: IconButton(
                    onPressed: () {
                      context.push('/address/${customer?.id}');
                    },
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
                if (customer != null) ...[
                  FutureBuilder<double>(
                    future: calculateDistanceFromCustomer(customer),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            const SizedBox(
                              height: 16, // Adjust height to make the loader smaller
                              width: 16, // Adjust width to make the loader smaller
                              child: CircularProgressIndicator(strokeWidth: 2), // Smaller loader
                            ),
                            const SizedBox(width: 10),
                            const Text("Calculating..."),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        final distance = snapshot.data!;
                        final multipliedDistance = multiplyDistance(distance);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text("Distance: "),
                            Text('${distance.toStringAsFixed(0)} km'),
                            const SizedBox(width: 10),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget displayAddress(BuildContext context, Customer? customer) {
    final address = getDefaultAddress(customer?.addresses ?? []);
    if (address == null) {
      return TextButton(
        onPressed: () {
          context.push('/address/${customer?.id}');
        },
        child: const Text("Add Address"),
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Text(
              truncateText(address.contact.name, 20),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              " | ${address.contact.phone}",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[400]),
            ),
          ],
        ),
        Text(
          truncateText(address.getFormattedLocation(), 40),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
              fontSize: 12),
        ),
      ],
    );
  }

  Address? getDefaultAddress(List<Address> addresses) {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Function to calculate distance from the customer's address using the utility functions
  Future<double> calculateDistanceFromCustomer(Customer? customer) async {
    final address = getDefaultAddress(customer?.addresses ?? []);
    if (address != null) {
      final customerAddress = address.getFormattedLocation();
      final coordinates = await convertAddressToLatLng(customerAddress);
      if (coordinates != null) {
        final distance = calculateDistance(shopLatitude, shopLongitude, coordinates[0], coordinates[1], customerAddress);
        return distance; // Return the original distance
      }
    }
    throw Exception('Address not found or no coordinates available');
  }
}
