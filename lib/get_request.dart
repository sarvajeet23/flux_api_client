
import 'package:flux_api_client/service/base_request.dart';
import 'package:http/http.dart' as http;


class GetRequest<T> extends BaseRequest<T> {
  GetRequest({
    required super.url,
    required super.fromJson,
    super.shouldPrintErrors,
    super.shouldPrintStackTrace,
  });

  Future<List<T>?> fetchProducts() async {
    return await handleRequest(() => http.get(Uri.parse(url)));
  }
}
