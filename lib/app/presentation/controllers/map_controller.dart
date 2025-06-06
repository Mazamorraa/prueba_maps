import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:prueba_maps/app/core/services/favorites_services.dart';
import 'package:prueba_maps/app/domain/repositories/place_repository.dart';

class MapController extends GetxController {
  final currentPosition = Rxn<Position>();
  final markers = <Marker>[].obs;
  final selectedPlaceType = ''.obs;
  final Map<String, BitmapDescriptor> icons = {};
  final isLoadingPlaces = false.obs;
  final searchResults = <SearchResult>[].obs;
  final isSearching = false.obs;
  final favoritesService = FavoritesServices();
  var showOnlyFavorites = false.obs;
  var selectedCategory = ''.obs;

  late GoogleMapController mapController;
  late PlaceRepository _placeRepository;

  @override
  void onInit() {
    super.onInit();
    _placeRepository = PlaceRepository(
      "AIzaSyCuA6hPrDqUMYcI7ksuB9iiYjYw22l6L8E",
    );
    loadCustomIcons();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showError('Los servicios de ubicación están desactivados.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        showError('Permiso de ubicación denegado.');
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = pos;
    } catch (e) {
      showError('Error al obtener la ubicación: $e');
    }
  }

  void showError(String message) {
    Get.snackbar(
      'Ubicación',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void changePlaceType(String newType) {
    selectedPlaceType.value = newType;
    loadNearbyPlaces(newType);
  }

  Future<void> loadNearbyPlaces(String type) async {
    isLoadingPlaces.value = true;

    final pos = currentPosition.value;
    if (pos == null) {
      isLoadingPlaces.value = false;
      return;
    }

    final places = await _placeRepository.getNearbyPlaces(
      lat: pos.latitude,
      lng: pos.longitude,
      type: type,
    );

    final List<Marker> tempMarkers = [];

    for (var place in places) {
      final location = place.geometry?.location;
      if (location == null) continue;

      final types = place.types ?? [];
      String? placeType;
      for (var t in types) {
        if (icons.containsKey(t)) {
          placeType = t;
          break;
        }
      }

      final icon = icons[placeType] ?? BitmapDescriptor.defaultMarker;

      tempMarkers.add(
        Marker(
          markerId: MarkerId(place.placeId ?? place.name ?? ''),
          position: LatLng(location.lat!, location.lng!),
          infoWindow: InfoWindow(
            title: place.name,
            onTap: () => loadPlaceDetails(place.placeId),
          ),
          icon: icon,
        ),
      );
    }

    markers.assignAll(tempMarkers);

    if (tempMarkers.isNotEmpty) {
      fitMapToMarkers(tempMarkers);
    } else {
      Get.snackbar(
        "Sin resultados",
        "No se encontraron lugares del tipo seleccionado cerca.",
        backgroundColor: Colors.orange[100],
        colorText: Colors.black,
      );
    }

    isLoadingPlaces.value = false;
  }

  // Recargar lugares cercanos al cambiar el tipo de lugar
  void reloadNearby() {
    if (selectedPlaceType.value.isNotEmpty) {
      loadNearbyPlaces(selectedPlaceType.value);
    }
  }

  Future<void> loadCustomIcons() async {
    icons['restaurant'] = await _loadIcon(
      'assets/icons/restaurante.png',
      width: 48,
    );
    icons['hospital'] = await _loadIcon('assets/icons/hospital.png', width: 48);
    icons['park'] = await _loadIcon('assets/icons/parque.png', width: 48);
    icons['gym'] = await _loadIcon('assets/icons/gym.png', width: 48);
    icons['store'] = await _loadIcon('assets/icons/tienda.png', width: 48);
    icons['cafe'] = await _loadIcon('assets/icons/cafe.png', width: 48);
    icons['pharmacy'] = await _loadIcon('assets/icons/farmacia.png', width: 48);
    icons['bank'] = await _loadIcon('assets/icons/banco.png', width: 48);
    icons['lodging'] = await _loadIcon('assets/icons/hotel.png', width: 48);
    icons['gas_station'] = await _loadIcon(
      'assets/icons/gasolinera.png',
      width: 48,
    );
  }

  Future<BitmapDescriptor> _loadIcon(String path, {int width = 64}) async {
    final image = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(width.toDouble(), width.toDouble())),
      path,
    );
    return image;
  }

  Future<void> searchPlacesByText(String query) async {
    isSearching.value = true;

    final response = await _placeRepository.searchByText(query);
    searchResults.assignAll(response);
    isSearching.value = false;

    if (response.isNotEmpty) {
      final first = response.first.geometry?.location;
      if (first != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(first.lat!, first.lng!), 15),
        );
      }

      final List<Marker> tempMarkers = [];

      for (var place in response) {
        final location = place.geometry?.location;
        if (location == null) continue;

        final types = place.types ?? [];
        String? placeType;

        for (var t in types) {
          if (icons.containsKey(t)) {
            placeType = t;
            break;
          }
        }

        final icon = icons[placeType] ?? BitmapDescriptor.defaultMarker;

        tempMarkers.add(
          Marker(
            markerId: MarkerId(place.placeId ?? place.name ?? ''),
            position: LatLng(location.lat!, location.lng!),
            infoWindow: InfoWindow(
              title: place.name,
              snippet: place.formattedAddress,
              onTap: () => showPlaceDetails(place),
            ),
            icon: icon,
          ),
        );
      }

      markers.assignAll(tempMarkers);
    } else {
      Get.snackbar(
        "Sin resultados",
        "No se encontraron lugares con ese nombre.",
        backgroundColor: Colors.orange[100],
        colorText: Colors.black,
      );
    }
  }

  void showPlaceDetails(SearchResult place) {
    final placeId = place.placeId ?? place.name ?? '';
    bool isFav = favoritesService.isFavorite(placeId);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      place.name ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        favoritesService.toggleFavorite(placeId);
                        setState(() {
                          isFav = !isFav;
                        });
                      },
                    ),
                  ],
                ),
                if (place.formattedAddress != null) ...[
                  Text(place.formattedAddress!, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                ],
                if (place.rating != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${place.rating}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> showFavoritesOnMap() async {
    final places = await favoritesService.getFavoritePlaces(
      _placeRepository.googlePlace,
    );

    final List<Marker> tempMarkers = [];

    for (var place in places) {
      final location = place.geometry?.location;
      if (location == null) continue;

      String? placeType;
      for (var t in place.types ?? []) {
        if (icons.containsKey(t)) {
          placeType = t;
          break;
        }
      }

      final icon = icons[placeType] ?? BitmapDescriptor.defaultMarker;

      tempMarkers.add(
        Marker(
          markerId: MarkerId(place.placeId ?? place.name ?? ''),
          position: LatLng(location.lat!, location.lng!),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.formattedAddress,
            onTap: () => showPlaceDetails(place),
          ),
          icon: icon,
        ),
      );
    }

    markers.assignAll(tempMarkers);

    if (places.isNotEmpty) {
      final first = places.first.geometry?.location;
      if (first != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(first.lat!, first.lng!), 14),
        );
      }
    }
  }

  //Detalles de un lugar específico

  Future<void> loadPlaceDetails(String? placeId) async {
    if (placeId == null) return;

    final response = await _placeRepository.googlePlace.details.get(placeId);
    final result = response?.result;
    if (result != null) {
      showPlaceDetails(
        SearchResult(
          name: result.name,
          placeId: result.placeId,
          geometry: result.geometry,
          formattedAddress: result.formattedAddress,
          rating: result.rating,
          types: result.types,
        ),
      );
    }
  }

  void fitMapToMarkers(List<Marker> markers) {
    if (markers.isEmpty) return;

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }
}
