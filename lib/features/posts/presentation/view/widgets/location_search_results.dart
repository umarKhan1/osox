import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:osox/features/posts/domain/models/location_model.dart';

class LocationSearchResults extends StatelessWidget {
  const LocationSearchResults({
    required this.results,
    required this.onSelectLocation,
    super.key,
  });

  final List<LocationModel> results;
  final ValueChanged<LocationModel> onSelectLocation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(top: 4.h),
      child: Container(
        constraints: BoxConstraints(maxHeight: 200.h),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final location = results[index];
            return ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(location.name),
              subtitle: Text(
                location.address ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => onSelectLocation(location),
            );
          },
        ),
      ),
    );
  }
}
