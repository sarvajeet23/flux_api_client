# Flux_api_client

A Flutter package for handling HTTP requests easily and efficiently with dynamic response mapping.

## Features

- Supports GET, POST, PUT, and DELETE HTTP requests.
- Simple JSON serialization and deserialization.
- Customizable error handling with logging options.
- Easy integration with Flutter applications.

## Getting Started

### Creating a Model Class

Define a model class that represents the data you expect from the API. For example, for a `Product` entity:

```dart
class Product {
  final int id;
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}
##---------------------------- Creating a Method ----------------------------##


class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}
//Products is model  class

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Products>?> futureProducts;
  final String url = 'https://jsonplaceholder.typicode.com/users';
// init
  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }
// fetchProducts is method

  Future<List<Products>?> fetchProducts() async {
    final getRequest = GetRequest<Products>(
      url: url,
      fromJson: (json) => Products.fromJson(json),
    );
    return await getRequest.fetchProducts();
  }
//  PostRequest is method

  Future<void> createProduct() async {
    final newProduct = Products(id: null, name: "shiboo", username: "sarvajeet");

    final postRequest = PostRequest<Products>(
      url: url,
      fromJson: (json) => Products.fromJson(json),
      body: newProduct.toJson(),
    );

    final response = await postRequest.send();
    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product Created: ${response.name}')),
      );

      // Fetch products after creation
      setState(() {
        futureProducts = fetchProducts(); // Re-fetch the products
      });
    }
  }
// DeleteRequest  is method

  Future<void> deleteProduct(int id) async {
    final deleteRequest = DeleteRequest<Products>(
      url: '$url/$id',
      fromJson: (json) => Products.fromJson(json),
      shouldPrintErrors: true,
      shouldPrintStackTrace: true,
    );

    final isDeleted = await deleteRequest.delete();
    if (isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Deleted Successfully.')),
      );
      // Fetch products after deletion
      setState(() {
        futureProducts = fetchProducts(); // Re-fetch the products
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting product.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: FutureBuilder<List<Products>?>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];

                return ListTile(
                  title: Text(product.id.toString()),
                  subtitle: Text(product.name ?? "null"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteProduct(product.id!), // Corrected here
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createProduct,
        tooltip: 'Create Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
###----------------------------------- ClientService with GetX Example ---------------------------------------------------####

## ClientService.dart

```dart
class ClientService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';
  final String usersEndpoint = '/users';

  /// Fetch a list of products from the API.
  Future<List<Product>?> fetchProducts() async {
    try {
      final getRequest = GetRequest<Product>(
        responsePrint: true,
        url: '$baseUrl$usersEndpoint',
        fromJson: (json) => Product.fromJson(json),
      );
      return await getRequest.fetchProducts();
    } catch (e) {
      // Handle error (e.g., log the error)
      return null;
    }
  }

  /// Create a new product in the API.
  Future<Product?> createProduct(Product product) async {
    try {
      final postRequest = PostRequest<Product>(
        url: '$baseUrl$usersEndpoint',
        fromJson: (json) => Product.fromJson(json),
        body: product.toJson(),
      );
      return await postRequest.send();
    } catch (e) {
      // Handle error
      return null;
    }
  }

  /// Delete a product by its ID.
  Future<bool> deleteProduct(int id) async {
    try {
      final deleteRequest = DeleteRequest<Product>(
        url: '$baseUrl$usersEndpoint/$id',
        fromJson: (json) => Product.fromJson(json),
        shouldPrintErrors: true,
        shouldPrintStackTrace: true,
      );
      return await deleteRequest.delete();
    } catch (e) {
      // Handle error
      return false;
    }
  }
}
#-------controller----------#
class ProductsController extends GetxController {
  final ClientService productService = ClientService();
  var products = <Product>[].obs; // Use observable list
  var isLoading = true.obs; // Use observable for loading state

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  /// Fetch products from the API
  Future<void> fetchProducts() async {
    _setLoading(true);
    try {
      final fetchedProducts = await productService.fetchProducts();
      products.value = fetchedProducts ?? [];
    } catch (e) {
      _showSnackbar('Error', 'Failed to fetch products.');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new product
  Future<void> createProduct() async {
    final newProduct = Product(id: null, name: "shiboo", username: "sarvajeet");
    try {
      final response = await productService.createProduct(newProduct);
      if (response != null) {
        products.add(response); // Automatically updates the UI
        _showSnackbar('Success', 'Product Created: ${response.name}');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to create product.');
    }
  }

  /// Delete a product by ID
  Future<void> deleteProduct(int id) async {
    try {
      final isDeleted = await productService.deleteProduct(id);
      if (isDeleted) {
        products.removeWhere((product) => product.id == id);
        _showSnackbar('Success', 'Product Deleted Successfully.');
      } else {
        _showSnackbar('Error', 'Error deleting product.');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to delete product.');
    }
  }

  /// Private method to set loading state
  void _setLoading(bool loading) {
    isLoading.value = loading; // Update observable
  }

  /// Private method to show a snackbar
  void _showSnackbar(String title, String message) {
    Get.snackbar(title, message);
  }
}
