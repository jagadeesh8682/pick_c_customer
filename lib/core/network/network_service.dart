abstract class NetworkService {
  Future<dynamic> getGetApiResponse(String url);
  Future<dynamic> getGetApiResponseUnauthenticated(String url);
  Future<dynamic> getPostApiResponse(String url, [dynamic data]);
  Future<dynamic> getPostApiResponseUnauthenticated(String url, [dynamic data]);
  Future<dynamic> getPutApiResponse(String url, [dynamic data]);
  Future<dynamic> getDeleteApiResponse(String url);
}
