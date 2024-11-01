// /lib/services/post_request.dart

import 'service/base_request.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostRequest<T> extends BaseRequest<T> {
  final Map<String, dynamic> body;

  PostRequest({
    required super.url,
    required super.fromJson,
    required this.body,
    super.shouldPrintErrors,
    super.shouldPrintStackTrace,
  });

  Future<List<T>?> send() async {
    return await handleRequest(() => http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body),
        ));
  }
}
