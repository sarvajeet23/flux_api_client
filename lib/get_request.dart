// /lib/services/get_request.dart

import 'dart:convert';

import 'package:flux_api_client/service/base_request.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class GetRequest<T> extends BaseRequest<T> {
  final bool responsePrint; // New parameter for response printing

  GetRequest({
    required super.url,
    required super.fromJson,
    super.shouldPrintErrors,
    super.shouldPrintStackTrace,
    this.responsePrint = false, // Default to false
  });

  Future<List<T>?> fetchProducts() async {
    return await handleRequest(() => http.get(Uri.parse(url)));
  }

  // Override the handleRequest to include response printing
  @override
  Future<List<T>?> handleRequest(
      // ignore: avoid_renaming_method_parameters
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      if (responsePrint) {
        log('Response Status Code: ${response.statusCode}');
        log('Response Body: ${response.body}');
      }

      // Check if the response is successful
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((item) => fromJson(item)).toList();
      } else {
        if (shouldPrintErrors == true) {
          log('Error: ${response.statusCode}');
        }
        return null;
      }
    } catch (error) {
      if (shouldPrintErrors == true) {
        log('Error: $error');
      }
      return null;
    }
  }
}
