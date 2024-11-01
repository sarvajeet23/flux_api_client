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
##-------- Creating a Method --------------##


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

