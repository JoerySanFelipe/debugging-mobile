import 'package:agritechv2/models/transaction/OrderItems.dart';
import 'package:agritechv2/models/transaction/TransactionType.dart';
import 'package:flutter/material.dart';

import '../../../models/transaction/TransactionSchedule.dart';
import '../../../models/address_info.dart'; // Import the AddressInfo class
import '../../../utils/Constants.dart';
import '../../custom widgets/order_details_data.dart';

class OrderSummary extends StatefulWidget {
  final List<OrderItems> orders;
  final TransactionType type;

  const OrderSummary({super.key, required this.orders, required this.type});

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  // State to track the visibility of address details
  bool showAddressDetails = false;

  @override
  Widget build(BuildContext context) {
    final _schedule = TransactionSchedule.initialize();
    final shipping = _computeShippingFee();
    final total = _computeTotalCost(shipping);
    final baseShipping = _computeBaseShippingFee(); // Calculate base shipping separately

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          const Divider(),
          _buildOrderSummary(shipping, total, _schedule),
          _buildToggleDetailsButton(),
          if (showAddressDetails) _buildAddressDetails(baseShipping), // Pass base shipping
        ],
      ),
    );
  }

  // Method to compute the total shipping fee (including distance fee)
  double _computeShippingFee() {
    final shipping = widget.type == TransactionType.DELIVERY
        ? computeShipping(widget.orders).toDouble() // Ensure this is a double
        : 0.0; // Ensure this is a double

    // Only add distance fee if transaction type is DELIVERY
    final distanceFee = widget.type == TransactionType.DELIVERY
        ? AddressInfo.addressDistanceFee.toDouble() // Cast to double
        : 0.0; // Ensure this is a double

    return shipping + distanceFee; // Both variables are now double
  }

  // Method to compute the base shipping fee without distance fee
  double _computeBaseShippingFee() {
    return widget.type == TransactionType.DELIVERY
        ? computeShipping(widget.orders).toDouble() // Cast to double
        : 0.0; // Ensure this is a double
  }

  // Method to compute the total order cost (including shipping and distance fees)
  double _computeTotalCost(double shipping) {
    return computeTotalOrder(widget.orders) + shipping;
  }

  // Build the main order summary details
  Widget _buildOrderSummary(double shipping, double total, TransactionSchedule _schedule) {
    return Column(
      children: [
        OrderDetailsData(
          title: "Total items",
          value: "${countOrders(widget.orders)}",
        ),
        OrderDetailsData(
          title: "Item Total",
          value: formatPrice(computeTotalOrder(widget.orders)),
        ),
        OrderDetailsData(
          title: "Shipping Fee",
          value: formatPrice(shipping),
        ),
        OrderDetailsData(
          title: widget.type == TransactionType.DELIVERY
              ? "Estimated Delivery Time"
              : "Estimated Pick up Time",
          value: _schedule.getFormatedSchedule(),
        ),
        OrderDetailsData(
          title: "Total",
          value: formatPrice(total),
        ),
      ],
    );
  }

  // Toggle button to show/hide address details
  Widget _buildToggleDetailsButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          showAddressDetails = !showAddressDetails;
        });
      },
      child: Text(
        showAddressDetails ? "Hide Details" : "Show More Details",
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Build the additional address details
  Widget _buildAddressDetails(double baseShipping) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Divider(),
          OrderDetailsData(
            title: "Delivery Address",
            value: AddressInfo.customerAddress.isNotEmpty
                ? AddressInfo.customerAddress.length > 25
                ? "${AddressInfo.customerAddress.substring(0, 25)}..."
                : AddressInfo.customerAddress
                : "Address not available",
          ),
          OrderDetailsData(
            title: "Distance to Address",
            value: "${AddressInfo.addressDistance.toInt()} km",
          ),
          OrderDetailsData(
            title: "Distance Rate",
            value: "₱12.00 per kilometer",
          ),
          OrderDetailsData(
            title: "Delivery Distance Fare",
            value: widget.type == TransactionType.PICK_UP
                ? "₱0.00" // Display zero for Pickup
                : "₱${AddressInfo.addressDistanceFee}", // Display actual fee for Delivery
          ),
          OrderDetailsData(
            title: "Base Fare",
            value: formatPrice(baseShipping), // Display the base shipping fee
          ),
        ],
      ),
    );
  }
}
