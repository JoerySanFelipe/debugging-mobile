import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product/Products.dart';

class ProductRepository {
  final FirebaseFirestore _firebaseFirestore;
  final String COLLECTION_NAME = 'products';
  List<Products> PRODUCTS = [];
  ProductRepository({
    FirebaseFirestore? firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;

  Future<Products> getProductById(String productId) async {
    try {
      final documentSnapshot = await _firebaseFirestore
          .collection(COLLECTION_NAME)
          .doc(productId)
          .get();

      if (documentSnapshot.exists) {
        final productData = documentSnapshot.data() as Map<String, dynamic>;
        final product = Products.fromJson(productData);
        return product;
      } else {
        throw Exception("Product not found");
      }
    } catch (e) {
      print("Error fetching product: ${e.toString()}");
      throw Exception(e.toString());
    }
  }

  Stream<Products> getProductStreamById(String productId) {
    return _firebaseFirestore
        .collection(COLLECTION_NAME)
        .doc(productId)
        .snapshots()
        .asyncMap((documentSnapshot) async {
      if (documentSnapshot.exists) {
        final productData = documentSnapshot.data() as Map<String, dynamic>;
        final product = Products.fromJson(productData);
        return product;
      } else {
        throw Exception("Product not found");
      }
    }).handleError((error) {
      print("Error fetching product: ${error.toString()}");
      throw Exception(error.toString());
    });
  }

  Stream<List<Products>> getAllProducts() {
    final controller = StreamController<List<Products>>();

    Future.delayed(const Duration(seconds: 1), () {
      try {
        _firebaseFirestore
            .collection(COLLECTION_NAME)
            .where('isHidden', isEqualTo: false) // Only show non-hidden products
            .orderBy('expiryDate')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
          try {
            final productsList = snapshot.docs.map((doc) {
              try {
                // Parse the product from Firestore data
                Products product = Products.fromJson(doc.data() ?? {});

                // Handle non-expiring products: if expiryDate is null, it's considered non-expiring
                if (product.expiryDate != null) {
                  // If expiryDate is set, check if it's expired
                  if (product.expiryDate!.isBefore(DateTime.now())) {
                    return null; // Skip expired products
                  }
                }

                // Filter variations with zero stocks
                product.variations = product.variations.where((variation) => variation.stocks > 0).toList();

                // If the product has no variations and zero stock, exclude it
                if (product.variations.isEmpty && product.stocks == 0) {
                  return null; // Exclude product with zero total stock
                }

                return product;
              } catch (e) {
                print('Error parsing product: $e');
                return null;
              }
            }).where((product) => product != null).toList(); // Remove null values

            // Make sure to remove nulls from the list before assigning it
            PRODUCTS = productsList.cast<Products>();  // Explicit cast to List<Products>
            controller.add(productsList.cast<Products>());  // Explicit cast to List<Products>
          } catch (e) {
            print('Error processing snapshot: $e');
            controller.addError(e);
          }
        }, onError: (error) {
          print('Firestore listen error: $error');
          controller.addError(error);
        });
      } catch (e) {
        print('Error initializing Firestore query: $e');
        controller.addError(e);
      }
    });

    controller.onCancel = controller.close;
    return controller.stream;
  }

// Check if the product has valid stocks (either through product's own stock or variations' stock)
  bool hasValidStocks(Products product) {
    int totalStock = product.stocks + product.variations.fold(0, (sum, variation) => sum + variation.stocks);
    return totalStock > 0;
  }



  Stream<List<Products>> getFeaturedProducts() {
    final controller = StreamController<List<Products>>();
    Future.delayed(const Duration(seconds: 1), () {
      _firebaseFirestore
          .collection(COLLECTION_NAME)
          .where('featured', isEqualTo: true)
          .where('expiryDate', isGreaterThan: DateTime.now())
          .where('isHidden', isEqualTo: false)
          .orderBy('expiryDate')
          .orderBy('createdAt')
          .snapshots()
          .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
        final productsList =
            snapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
          return Products.fromJson(doc.data() ?? {});
        }).toList();
        print("${productsList} Test");
        controller.add(productsList);
      });
    });
    return controller.stream;
  }

  Future<List<Products>> searchProduct(String name) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection(COLLECTION_NAME)
        .where("name", isEqualTo: name)
        .get();

    List<Products> productList = [];
    querySnapshot.docs.forEach((doc) {
      Products product = Products.fromJson(doc.data() as Map<String, dynamic>);
      productList.add(product);
    });

    return productList;
  }
}
