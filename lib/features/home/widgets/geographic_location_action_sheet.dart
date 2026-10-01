import 'dart:ui';
import 'package:flutter/material.dart';

/// iOS-style action sheet modal for Geographic Location actions matching the ezBookkeeping UI design.
class GeographicLocationActionSheet extends StatelessWidget {
  final String? currentLocation;
  final ValueChanged<String>? onUpdateLocation;
  final VoidCallback? onClearLocation;
  final VoidCallback? onShowMap;

  const GeographicLocationActionSheet({
    super.key,
    this.currentLocation,
    this.onUpdateLocation,
    this.onClearLocation,
    this.onShowMap,
  });

  static const Color _copperAccent = Color(0xFFC86D3B);

  /// Displays the [GeographicLocationActionSheet] modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    String? currentLocation,
    ValueChanged<String>? onUpdateLocation,
    VoidCallback? onClearLocation,
    VoidCallback? onShowMap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => GeographicLocationActionSheet(
        currentLocation: currentLocation,
        onUpdateLocation: onUpdateLocation,
        onClearLocation: onClearLocation,
        onShowMap: onShowMap,
      ),
    );
  }

  bool get _hasLocation {
    if (currentLocation == null) return false;
    final trimmed = currentLocation!.trim().toLowerCase();
    return trimmed.isNotEmpty &&
        trimmed != 'no location' &&
        trimmed != 'none' &&
        trimmed != 'select location';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockBg = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.95)
        : const Color(0xFFF2F2F7).withValues(alpha: 0.95);
    final dividerColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    final showOnMapColor = _hasLocation
        ? _copperAccent
        : _copperAccent.withValues(alpha: 0.45);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 8,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Block 1: Update & Clear Geographic Location
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: blockBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Update Geographic Location
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              if (onUpdateLocation != null) {
                                // Default simulated updated geographic location
                                onUpdateLocation!(
                                  'Current Location (37.7749° N, 122.4194° W)',
                                );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Geographic location updated'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              alignment: Alignment.center,
                              child: const Text(
                                'Update Geographic Location',
                                style: TextStyle(
                                  color: _copperAccent,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Divider(height: 1, thickness: 0.6, color: dividerColor),

                        // 2. Clear Geographic Location
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              if (onClearLocation != null) {
                                onClearLocation!();
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Geographic location cleared'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              alignment: Alignment.center,
                              child: const Text(
                                'Clear Geographic Location',
                                style: TextStyle(
                                  color: _copperAccent,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Block 2: Show on the map
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: blockBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (onShowMap != null) {
                            onShowMap!();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _hasLocation
                                      ? 'Showing location "$currentLocation" on map'
                                      : 'No geographic location set to show on map',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Center(
                          child: Text(
                            'Show on the map',
                            style: TextStyle(
                              color: showOnMapColor,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Block 3: Cancel
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      color: blockBg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: _copperAccent,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
