import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class PutRequest<T> {
  final String url;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> body;
  final Map<String, String> headers;
  final bool expectList;
  final bool requestPrint;
  final bool responsePrint;
  final bool shouldPrintErrors;
  final bool shouldPrintStackTrace;

  PutRequest({
    required this.url,
    required this.fromJson,
    required this.body,
    this.headers = const {'Content-Type': 'application/json'},
    this.expectList = false,
    this.requestPrint = false,
    this.responsePrint = false,
    this.shouldPrintErrors = false,
    this.shouldPrintStackTrace = false,
  });

  Future<dynamic> update() async {
    try {
      if (requestPrint) {
        log('PUT Request URL: $url');
        log('Request Body: ${json.encode(body)}');
      }

      final response = await http.put(
        Uri.parse(url),
        body: json.encode(body),
        headers: headers,
      );

      if (responsePrint) {
        log('Response Status Code: ${response.statusCode}');
        log('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (expectList && decodedResponse is List) {
          // Parse each item in the list and cast to Map<String, dynamic>
          return decodedResponse
              .map((item) => fromJson(Map<String, dynamic>.from(item)))
              .toList();
        } else if (decodedResponse is Map) {
          // Cast to Map<String, dynamic> for single object
          return fromJson(Map<String, dynamic>.from(decodedResponse));
        } else {
          if (shouldPrintErrors) {
            log('Unexpected response format');
          }
          return null;
        }
      } else {
        if (shouldPrintErrors) {
          log('Error: ${response.statusCode} - ${response.body}');
        }
        return null;
      }
    } catch (error, stacktrace) {
      if (shouldPrintErrors) {
        log('Error: $error');
      }
      if (shouldPrintStackTrace) {
        log('StackTrace: $stacktrace');
      }
      return null;
    }
  }
}
