import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_place/google_place.dart';

class FavoritesServices {
  final _storage = GetStorage();

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  String get _key => 'favorite_places_$_uid';

  List<String> get favorites => List<String>.from(_storage.read(_key) ?? []);

  bool isFavorite(String placeId) {
    return favorites.contains(placeId);
  }

  void toggleFavorite(String placeId) {
    final favs = favorites;
    if (favs.contains(placeId)) {
      favs.remove(placeId);
    } else {
      favs.add(placeId);
    }
    _storage.write(_key, favs);
  }

  Future<List<SearchResult>> getFavoritePlaces(GooglePlace googlePlace) async {
    final favs = favorites;
    final List<SearchResult> results = [];

    for (var placeId in favs) {
      final response = await googlePlace.details.get(placeId);
      final place = response?.result;
      if (place != null) {
        results.add(
          SearchResult(
            name: place.name,
            placeId: placeId,
            geometry: place.geometry,
            formattedAddress: place.formattedAddress,
            rating: place.rating,
            types: place.types,
          ),
        );
      }
    }

    return results;
  }
}
