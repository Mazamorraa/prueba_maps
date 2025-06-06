import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:prueba_maps/app/core/constants/places_types.dart';
import 'package:prueba_maps/app/presentation/controllers/auth_controllers.dart';
import 'package:prueba_maps/app/presentation/controllers/map_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final user = controller.firebaseUser.value;
    final mapCtrl = Get.isRegistered<MapController>()
        ? Get.find<MapController>()
        : Get.put(MapController());

    // Detectar orientación de la pantalla
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // interfaz principal
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Interactivo')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Encabezado con información del usuario
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1365B3)),
              accountEmail: Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              accountName: null,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await controller.logout();
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        final pos = mapCtrl.currentPosition.value;
        if (pos == null) {
          // Indicador de carga mientras se obtiene la ubicación
          return Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            // Google Map
            Positioned.fill(
              child: GoogleMap(
                onMapCreated: mapCtrl.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(pos.latitude, pos.longitude),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                markers: Set<Marker>.of(mapCtrl.markers),
              ),
            ),
            // UI responsiva según orientación
            if (isPortrait) ...[
              // Barra de búsqueda
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar lugar por nombre',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        mapCtrl.searchPlacesByText(value);
                      }
                    },
                  ),
                ),
              ),
              // Menú desplegable
              Positioned(
                top: 110,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: DropdownButtonFormField<String>(
                    value: mapCtrl.selectedCategory.value.isEmpty
                        ? null
                        : mapCtrl.selectedCategory.value,
                    decoration: const InputDecoration(
                      hintText: "Escoja un lugar a buscar",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        mapCtrl.selectedCategory.value = value;
                        mapCtrl.showOnlyFavorites.value = false;
                        mapCtrl.loadNearbyPlaces(value);
                      }
                    },
                    items: placeTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type['value'],
                            enabled: type['value']!.isNotEmpty,
                            child: Text(
                              type['name']!,
                              style: type['value']!.isEmpty
                                  ? const TextStyle(color: Colors.grey)
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              // Indicador de cargando contenido
              Positioned(
                top: 160,
                left: 16,
                right: 16,
                child: Obx(() {
                  if (mapCtrl.isLoadingPlaces.value) {
                    return Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              "🔍 Buscando lugares...",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
              // Botón para mostrar solo favoritos
              Positioned(
                bottom: 32,
                left: 16,
                child: Obx(
                  () => FloatingActionButton.extended(
                    backgroundColor: mapCtrl.showOnlyFavorites.value
                        ? Color(0xFFfa7a2e)
                        : Theme.of(context).primaryColor,
                    onPressed: () {
                      if (mapCtrl.showOnlyFavorites.value) {
                        mapCtrl.reloadNearby();
                      } else {
                        mapCtrl.showFavoritesOnMap();
                      }
                      mapCtrl.showOnlyFavorites.toggle();
                    },
                    icon: Icon(
                      mapCtrl.showOnlyFavorites.value
                          ? Icons.star
                          : Icons.star_border,
                      color: mapCtrl.showOnlyFavorites.value
                          ? Colors.amber
                          : Colors.white,
                    ),
                    label: Text(
                      mapCtrl.showOnlyFavorites.value
                          ? 'Solo ver favoritos'
                          : 'Solo ver favoritos',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // En landscape, controles en barra horizontal superior
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de búsqueda
                      SizedBox(
                        width: 220,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(10),
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Buscar lugar',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                mapCtrl.searchPlacesByText(value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Menú desplegable de categorías
                      SizedBox(
                        width: 200,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(10),
                          child: DropdownButtonFormField<String>(
                            value: mapCtrl.selectedCategory.value.isEmpty
                                ? null
                                : mapCtrl.selectedCategory.value,
                            decoration: const InputDecoration(
                              hintText: "Tipo de lugar",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            isExpanded: true,
                            onChanged: (value) {
                              if (value != null && value.isNotEmpty) {
                                mapCtrl.selectedCategory.value = value;
                                mapCtrl.showOnlyFavorites.value = false;
                                mapCtrl.loadNearbyPlaces(value);
                              }
                            },
                            items: placeTypes
                                .map(
                                  (type) => DropdownMenuItem<String>(
                                    value: type['value'],
                                    enabled: type['value']!.isNotEmpty,
                                    child: Text(
                                      type['name']!,
                                      style: type['value']!.isEmpty
                                          ? const TextStyle(color: Colors.grey)
                                          : null,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Botón para mostrar solo favoritos
                      Obx(
                        () => FloatingActionButton.extended(
                          backgroundColor: mapCtrl.showOnlyFavorites.value
                              ? Color(0xFFfa7a2e)
                              : Theme.of(context).primaryColor,
                          onPressed: () {
                            if (mapCtrl.showOnlyFavorites.value) {
                              mapCtrl.reloadNearby();
                            } else {
                              mapCtrl.showFavoritesOnMap();
                            }
                            mapCtrl.showOnlyFavorites.toggle();
                          },
                          icon: Icon(
                            mapCtrl.showOnlyFavorites.value
                                ? Icons.star
                                : Icons.star_border,
                            color: mapCtrl.showOnlyFavorites.value
                                ? Colors.amber
                                : Colors.white,
                          ),
                          label: Text(
                            mapCtrl.showOnlyFavorites.value
                                ? 'Solo favoritos'
                                : 'Solo favoritos',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Indicador de cargando contenido
                      Obx(() {
                        if (mapCtrl.isLoadingPlaces.value) {
                          return Material(
                            color: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    "🔍 Buscando...",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}
