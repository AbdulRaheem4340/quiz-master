// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:local_service_marketplace/api/service.dart';
// import 'package:local_service_marketplace/models/location.dart';

// class MapSearchScreen extends StatefulWidget {
//   const MapSearchScreen({Key? key}) : super(key: key);

//   @override
//   State<MapSearchScreen> createState() => _MapSearchScreenState();
// }

// class _MapSearchScreenState extends State<MapSearchScreen> {
//   final MapController _mapController = MapController();
//   final ApiService _apiService = ApiService();
//   final TextEditingController _searchController = TextEditingController();

//   List<MapLocation> _searchResults = [];
//   MapLocation? _selectedLocation;
//   bool _isLoading = false;
//   bool _showSearchResults = false;
//   bool _isBlocked = false;

//   // Debounce timer to prevent too many API calls
//   Timer? _debounceTimer;

//   LatLng _currentCenter = LatLng(29.402729, 71.651724);
//   double _currentZoom = 13.0;

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _mapController.dispose();
//     _debounceTimer?.cancel();
//     super.dispose();
//   }

//   // Debounced search - waits 1 second after user stops typing
//   void _onSearchChanged(String query) {
//     _debounceTimer?.cancel();

//     if (query.isEmpty) {
//       setState(() {
//         _showSearchResults = false;
//         _searchResults = [];
//       });
//       return;
//     }

//     if (query.length < 3) {
//       return; // Don't search for very short queries
//     }

//     _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
//       _searchLocation(query);
//     });
//   }

//   Future<void> _searchLocation(String query) async {
//     if (query.isEmpty || _isBlocked) return;

//     setState(() {
//       _isLoading = true;
//       _showSearchResults = true;
//     });

//     final results = await _apiService.searchLocation(query);

//     setState(() {
//       _searchResults = results;
//       _isLoading = false;

//       if (results.isEmpty && _searchController.text.isNotEmpty) {
//         // Might be blocked
//       }
//     });
//   }

//   void _selectLocation(MapLocation location) {
//     setState(() {
//       _selectedLocation = location;
//       _currentCenter = LatLng(location.latitude, location.longitude);
//       _showSearchResults = false;
//       _searchController.clear();
//       _searchResults = [];
//     });

//     _mapController.move(_currentCenter, 16.0);
//   }

//   Future<void> _onMapTap(TapPosition tapPosition, LatLng point) async {
//     if (_isBlocked) {
//       _showBlockedMessage();
//       return;
//     }

//     setState(() => _isLoading = true);

//     final location = await _apiService.fetchLocationFromCoordinates(
//       latitude: point.latitude,
//       longitude: point.longitude,
//     );

//     setState(() {
//       if (location != null) {
//         _selectedLocation = location;
//         _currentCenter = point;
//       }
//       _isLoading = false;
//     });
//   }

//   void _showBlockedMessage() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           'API temporarily blocked. Please wait a few hours.',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Map View
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentCenter,
//               initialZoom: _currentZoom,
//               onTap: _onMapTap,
//               onPositionChanged: (position, hasGesture) {
//                 _currentZoom = position.zoom;
//               },
//             ),
//             children: [
//               // OpenStreetMap Tile Layer - Using alternative tile server
//               TileLayer(
//                 urlTemplate:
//                     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//                 userAgentPackageName: 'com.example.local_service_marketplace',
//                 maxZoom: 19,
//               ),

//               // Marker Layer
//               MarkerLayer(
//                 markers: [
//                   if (_selectedLocation != null)
//                     Marker(
//                       point: LatLng(
//                         _selectedLocation!.latitude,
//                         _selectedLocation!.longitude,
//                       ),
//                       width: 50,
//                       height: 50,
//                       child: const Icon(
//                         Icons.location_on,
//                         color: Colors.red,
//                         size: 40,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),

//           // Search Bar at Top
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 10,
//             left: 10,
//             right: 10,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black,
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Search Input
//                   TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search location (min 3 characters)...',
//                       prefixIcon: const Icon(Icons.search),
//                       suffixIcon: _searchController.text.isNotEmpty
//                           ? IconButton(
//                               icon: const Icon(Icons.clear),
//                               onPressed: () {
//                                 setState(() {
//                                   _searchController.clear();
//                                   _showSearchResults = false;
//                                   _searchResults = [];
//                                 });
//                               },
//                             )
//                           : null,
//                       border: InputBorder.none,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 14,
//                       ),
//                     ),
//                     onChanged: _onSearchChanged,
//                   ),

//                   // Loading indicator for search
//                   if (_isLoading && _showSearchResults)
//                     const LinearProgressIndicator(),

//                   // Search Results Dropdown
//                   if (_showSearchResults && _searchResults.isNotEmpty)
//                     Container(
//                       constraints: const BoxConstraints(maxHeight: 200),
//                       decoration: const BoxDecoration(
//                         border: Border(
//                           top: BorderSide(color: Colors.grey, width: 0.5),
//                         ),
//                       ),
//                       child: ListView.builder(
//                         shrinkWrap: true,
//                         padding: EdgeInsets.zero,
//                         itemCount: _searchResults.length,
//                         itemBuilder: (context, index) {
//                           final location = _searchResults[index];
//                           return ListTile(
//                             leading: const Icon(
//                               Icons.location_on,
//                               size: 20,
//                               color: Colors.red,
//                             ),
//                             title: Text(
//                               location.name ?? 'Unknown',
//                               style: const TextStyle(fontSize: 14),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             subtitle: Text(
//                               location.displayName ?? '',
//                               style: const TextStyle(fontSize: 11),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             dense: true,
//                             onTap: () => _selectLocation(location),
//                           );
//                         },
//                       ),
//                     ),

//                   // No results message
//                   if (_showSearchResults &&
//                       _searchResults.isEmpty &&
//                       !_isLoading &&
//                       _searchController.text.length >= 3)
//                     const Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Text(
//                         'No results found. Try a different search.',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // Selected Location Details (Bottom Card)
//           if (_selectedLocation != null)
//             Positioned(
//               bottom: 20,
//               left: 10,
//               right: 10,
//               child: Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Icon(Icons.location_on, color: Colors.red),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               _selectedLocation!.name ?? 'Selected Location',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.close, size: 20),
//                             padding: EdgeInsets.zero,
//                             constraints: const BoxConstraints(),
//                             onPressed: () {
//                               setState(() {
//                                 _selectedLocation = null;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         _selectedLocation!.displayName ??
//                             'No address available',
//                         style: const TextStyle(fontSize: 12),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             Column(
//                               children: [
//                                 const Text(
//                                   'Latitude',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 Text(
//                                   _selectedLocation!.latitude.toStringAsFixed(
//                                     6,
//                                   ),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               height: 30,
//                               width: 1,
//                               color: Colors.grey[300],
//                             ),
//                             Column(
//                               children: [
//                                 const Text(
//                                   'Longitude',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 Text(
//                                   _selectedLocation!.longitude.toStringAsFixed(
//                                     6,
//                                   ),
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Loading Overlay
//           if (_isLoading && !_showSearchResults)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black,
//                 child: const Center(
//                   child: Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: CircularProgressIndicator(),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),

//       // Floating Action Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _mapController.move(LatLng(29.402729, 71.651724), 16.0);
//         },
//         child: const Icon(Icons.my_location),
//       ),
//     );
//   }
// }
