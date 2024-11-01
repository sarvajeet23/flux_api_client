// /lib/services/base_request.dart

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

abstract class BaseRequest<T> {
  final String url;
  final T Function(Map<String, dynamic>) fromJson;
  final bool shouldPrintErrors;
  final bool shouldPrintStackTrace;

  BaseRequest({
    required this.url,
    required this.fromJson,
    this.shouldPrintErrors = false,
    this.shouldPrintStackTrace = false,
  });

  Future<List<T>?> handleRequest(
      Future<http.Response> Function() requestFunc) async {
    try {
      final response = await requestFunc();
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => fromJson(item)).toList();
      } else {
        throw Exception('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e, st) {
      if (shouldPrintErrors) {
        log('Error: $e');
      }
      if (shouldPrintStackTrace) {
        log('StackTrace: $st');
      }
      return null;
    }
  }
}
