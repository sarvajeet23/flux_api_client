library flux_api_client;

/// A library for handling various HTTP requests in Flutter.
///
/// This library provides classes for making GET, POST, PUT, and DELETE
/// requests easily and efficiently.

export 'delete_request.dart';
export 'get_request.dart';
export 'post_request.dart';
export 'put_request.dart';

/// A simple Calculator for demonstration purposes.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
