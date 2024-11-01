import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class PostRequest<T> {
  final String url;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, String> headers;
  final Map<String, dynamic> body;
  final bool requestPrint;
  final bool responsePrint;
  final bool shouldPrintErrors;
  final bool shouldPrintStackTrace;
  final bool expectList;

  PostRequest({
    required this.url,
    required this.fromJson,
    required this.body,
    this.headers = const {'Content-Type': 'application/json'},
    this.requestPrint = false,
    this.responsePrint = false,
    this.shouldPrintErrors = false,
    this.shouldPrintStackTrace = false,
    this.expectList = false,
  });

  Future<T?> send() async {
    try {
      if (requestPrint) {
        log('POST Request URL: $url');
        log('Request Body: ${json.encode(body)}');
      }

      final response = await http
          .post(
            Uri.parse(url),
            body: json.encode(body),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (responsePrint) {
        log('Response Status Code: ${response.statusCode}');
        log('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedResponse = json.decode(response.body);

        if (expectList && decodedResponse is List) {
          return decodedResponse
              .map((item) => fromJson(Map<String, dynamic>.from(item)))
              .toList() as T;
        } else if (!expectList && decodedResponse is Map) {
          return fromJson(Map<String, dynamic>.from(decodedResponse));
        } else {
          if (shouldPrintErrors) {
            log('Unexpected response format: $decodedResponse');
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
