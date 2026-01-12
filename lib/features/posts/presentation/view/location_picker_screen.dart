import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';
import 'package:osox/features/posts/presentation/cubit/location_picker_cubit.dart';
import 'package:osox/features/posts/presentation/cubit/location_picker_state.dart';
import 'package:osox/features/posts/presentation/view/widgets/location_confirm_button.dart';
import 'package:osox/features/posts/presentation/view/widgets/location_error_state.dart';
import 'package:osox/features/posts/presentation/view/widgets/location_loading_state.dart';
import 'package:osox/features/posts/presentation/view/widgets/location_search_bar.dart';
import 'package:osox/features/posts/presentation/view/widgets/location_search_results.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<LocationModel> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    context.read<LocationPickerCubit>().getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    final results = await context.read<LocationPickerCubit>().searchLocation(
      query,
    );
    setState(() {
      _searchResults = results.take(5).toList();
      _showSearchResults = _searchResults.isNotEmpty;
    });
  }

  void _selectSearchResult(LocationModel location) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
    );
    context.read<LocationPickerCubit>().selectLocation(
      location.latitude,
      location.longitude,
    );
    setState(() {
      _showSearchResults = false;
      _searchController.clear();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showSearchResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<LocationPickerCubit, LocationPickerState>(
        builder: (context, state) {
          if (state is LocationPickerLoading) {
            return LocationLoadingState(onCancel: () => context.pop());
          }

          if (state is LocationPickerError) {
            return LocationErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<LocationPickerCubit>().getCurrentLocation(),
              onGoBack: () => context.pop(),
            );
          }

          if (state is LocationPickerReady) {
            return _buildMapView(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMapView(LocationPickerReady state) {
    final hasSelection = state.selectedLocation != null;

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(state.currentLatitude, state.currentLongitude),
            zoom: 15,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onTap: (latLng) {
            context.read<LocationPickerCubit>().selectLocation(
              latLng.latitude,
              latLng.longitude,
            );
          },
          markers: {
            Marker(
              markerId: const MarkerId('selected'),
              position: LatLng(
                hasSelection
                    ? state.selectedLocation!.latitude
                    : state.currentLatitude,
                hasSelection
                    ? state.selectedLocation!.longitude
                    : state.currentLongitude,
              ),
            ),
          },
          myLocationEnabled: true,
        ),

        // Search Bar with Results
        Positioned(
          top: 16.h,
          left: 16.w,
          right: 16.w,
          child: Column(
            children: [
              LocationSearchBar(
                controller: _searchController,
                onChanged: _performSearch,
                onClear: _clearSearch,
              ),
              if (_showSearchResults && _searchResults.isNotEmpty)
                LocationSearchResults(
                  results: _searchResults,
                  onSelectLocation: _selectSearchResult,
                ),
            ],
          ),
        ),

        // Confirm Button
        Positioned(
          bottom: 30.h,
          left: 16.w,
          right: 16.w,
          child: LocationConfirmButton(
            hasSelection: hasSelection,
            onConfirm: () {
              final locationToReturn = hasSelection
                  ? state.selectedLocation
                  : LocationModel(
                      latitude: state.currentLatitude,
                      longitude: state.currentLongitude,
                      name: 'Current Location',
                    );
              context.pop(locationToReturn);
            },
          ),
        ),
      ],
    );
  }
}
