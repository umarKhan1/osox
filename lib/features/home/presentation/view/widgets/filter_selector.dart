import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterSelector extends StatefulWidget {
  const FilterSelector({required this.onFilterChanged, super.key});
  final void Function(int) onFilterChanged;

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  int _selectedIndex = 0;

  final List<String> _filterPaths = [
    'https://images.unsplash.com/photo-1541963463532-d68292c34b19?w=100',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=100',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100',
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=100',
    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100',
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterPaths.length,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onFilterChanged(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              width: isSelected ? 60.r : 45.r,
              height: isSelected ? 60.r : 45.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white24,
                  width: isSelected ? 3.r : 1.r,
                ),
                image: DecorationImage(
                  image: NetworkImage(_filterPaths[index]),
                  fit: BoxFit.cover,
                  colorFilter: isSelected
                      ? null
                      : ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.3),
                          BlendMode.darken,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
