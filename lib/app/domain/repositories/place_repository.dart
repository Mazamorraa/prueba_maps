import 'package:google_place/google_place.dart';

class PlaceRepository {
  final GooglePlace _googlePlace;

  PlaceRepository(String apiKey) : _googlePlace = GooglePlace(apiKey);

  GooglePlace get googlePlace => _googlePlace;

  Future<List<SearchResult>> getNearbyPlaces({
    required double lat,
    required double lng,
    String? type = 'restaurant',
    int radius = 3000,
  }) async {
    final response = await _googlePlace.search.getNearBySearch(
      Location(lat: lat, lng: lng),
      radius,
      type: type,
    );

    final places = response?.results ?? [];
    return places;
  }

  Future<List<SearchResult>> searchByText(String query) async {
    final response = await _googlePlace.search.getTextSearch(query);

    return response?.results ?? [];
  }
}
