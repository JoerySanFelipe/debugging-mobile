import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../styles/color_styles.dart';

class OptionalAddressPage extends StatelessWidget {
  const OptionalAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorStyle.brandRed,
        title: const Text('Address Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Icon
            const Center(
              child: Icon(
                Icons.location_on,
                color: ColorStyle.brandRed,
                size: 100,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              "Set Up Your Address",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Subtitle
            const Text(
              "Would you like to add your address now? This will make your first purchase process easier.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),

            // "Yes, Add Now" Button
            ElevatedButton.icon(
              onPressed: () {
                context.go('/create-address');// Redirect to add address page
              },
              icon: const Icon(Icons.add_location_alt),
              label: const Text("Yes, Add Now"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: ColorStyle.brandRed,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // "Maybe Later" Button
            OutlinedButton.icon(
              onPressed: () {
                context.go('/'); // Redirect to home page
              },
              icon: const Icon(Icons.home),
              label: const Text("Not Now"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                foregroundColor: ColorStyle.brandRed,
                side: BorderSide(color: ColorStyle.brandRed, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
