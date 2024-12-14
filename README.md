
# Flux API Client

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
  final int? id;
  final String name;
  final String username;

  Product({this.id, required this.name, required this.username});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
    };
  }
}
```

## ProductsPage

The `ProductsPage` is a simple UI for displaying a list of products, creating new products, and deleting existing ones.

```dart
class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>?> futureProducts;
  final String url = 'https://jsonplaceholder.typicode.com/users';

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>?> fetchProducts() async {
    final getRequest = GetRequest<Product>(
      url: url,
      fromJson: (json) => Product.fromJson(json),
    );
    return await getRequest.fetchProducts();
  }

  Future<void> createProduct() async {
    final newProduct = Product(id: null, name: "shiboo", username: "sarvajeet");

    final postRequest = PostRequest<Product>(
      url: url,
      fromJson: (json) => Product.fromJson(json),
      body: newProduct.toJson(),
    );

    final response = await postRequest.send();
    if (response != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product Created: ${response.name}')),
      );
      setState(() {
        futureProducts = fetchProducts();
      });
    }
  }

  Future<void> deleteProduct(int id) async {
    final deleteRequest = DeleteRequest<Product>(
      url: '$url/$id',
      fromJson: (json) => Product.fromJson(json),
      shouldPrintErrors: true,
      shouldPrintStackTrace: true,
    );

    final isDeleted = await deleteRequest.delete();
    if (isDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Deleted Successfully.')),
      );
      setState(() {
        futureProducts = fetchProducts();
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
      body: FutureBuilder<List<Product>?>(
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
                final product = products[index];

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteProduct(product.id!),
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
```

## ClientService with GetX Example

The `ClientService` class simplifies HTTP interactions for fetching, creating, and deleting products.

### ClientService.dart

```dart
class ClientService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';
  final String usersEndpoint = '/users';

  Future<List<Product>?> fetchProducts() async {
    try {
      final getRequest = GetRequest<Product>(
        responsePrint: true,
        url: '$baseUrl$usersEndpoint',
        fromJson: (json) => Product.fromJson(json),
      );
      return await getRequest.fetchProducts();
    } catch (e) {
      return null;
    }
  }

  Future<Product?> createProduct(Product product) async {
    try {
      final postRequest = PostRequest<Product>(
        url: '$baseUrl$usersEndpoint',
        fromJson: (json) => Product.fromJson(json),
        body: product.toJson(),
      );
      return await postRequest.send();
    } catch (e) {
      return null;
    }
  }

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
      return false;
    }
  }
}
```

### ProductsController

The `ProductsController` uses `GetX` to manage the state and interact with the `ClientService`.

```dart
class ProductsController extends GetxController {
  final ClientService productService = ClientService();
  var products = <Product>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

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

  Future<void> createProduct() async {
    final newProduct = Product(id: null, name: "shiboo", username: "sarvajeet");
    try {
      final response = await productService.createProduct(newProduct);
      if (response != null) {
        products.add(response);
        _showSnackbar('Success', 'Product Created: ${response.name}');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to create product.');
    }
  }

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

  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  void _showSnackbar(String title, String message) {
    Get.snackbar(title, message);
  }
}
```
