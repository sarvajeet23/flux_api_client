// /lib/services/delete_request.dart

import 'dart:developer';

import 'service/base_request.dart';
import 'package:http/http.dart' as http;

class DeleteRequest<T> extends BaseRequest<T> {
  DeleteRequest({
    required super.url,
    required super.fromJson,
    super.shouldPrintErrors,
    super.shouldPrintStackTrace,
  });

  Future<bool> delete() async {
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception(
            'Failed to delete. Status code: ${response.statusCode}');
      }
    } catch (e, st) {
      if (shouldPrintErrors) {
        log('Error: $e');
      }
      if (shouldPrintStackTrace) {
        log('StackTrace: $st');
      }
      throw Exception('Error occurred during deletion: $e');
    }
  }
}
