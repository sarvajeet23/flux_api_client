import 'dart:convert';

import 'package:flux_api_client/service/base_request.dart';
import 'package:http/http.dart' as http;

class PutRequest<T> extends BaseRequest<T> {
  final Map<String, dynamic> body;

  PutRequest({
    required super.url,
    required super.fromJson,
    required this.body,
    super.shouldPrintErrors,
    super.shouldPrintStackTrace,
  });

  Future<List<T>?> update() async {
    return await handleRequest(() => http.put(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        ));
  }
}
