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
