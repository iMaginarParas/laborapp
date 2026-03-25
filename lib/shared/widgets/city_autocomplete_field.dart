import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/location_service.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/theme/app_layout.dart';

/// A reusable autocomplete field for city selection with a floating dropdown.
///
/// Features:
/// - Scrollable dropdown (max 200px)
/// - Case-insensitive dynamic filtering
/// - Overlay-based dropdown (works in dialogs, sheets, and scrollable views)
/// - Debounced input (300ms)
/// - Form validation support
/// - Clear button support
class CityAutocompleteField extends StatefulWidget {
  final String? initialValue;
  final String hintText;
  final Function(String) onCitySelected;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final List<String>? customCityList;

  const CityAutocompleteField({
    super.key,
    this.initialValue,
    this.hintText = "Enter city",
    required this.onCitySelected,
    this.validator,
    this.controller,
    this.customCityList,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  late TextEditingController _controller;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredCities = [];
  bool _showDropdown = false;
  Timer? _debounce;
  bool _isLocating = false;

  Future<void> _handleCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final service = LocationService();
      final pos = await service.getCurrentPosition();
      if (pos != null) {
        final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          final city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? "Noida";
          _selectCity(city);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  // Default city list (can be expanded to 1000+)
  static const List<String> _defaultCityList = [
    "Mumbai", "Delhi", "Bangalore", "Hyderabad", "Ahmedabad", "Chennai", "Kolkata", "Surat", "Pune", "Jaipur",
    "Lucknow", "Kanpur", "Nagpur", "Indore", "Thane", "Bhopal", "Visakhapatnam", "Pimpri-Chinchwad", "Patna", "Vadodara",
    "Ghaziabad", "Ludhiana", "Agra", "Nashik", "Faridabad", "Meerut", "Rajkot", "Kalyan-Dombivli", "Vasai-Virar", "Varanasi",
    "Srinagar", "Aurangabad", "Dhanbad", "Amritsar", "Navi Mumbai", "Allahabad", "Ranchi", "Howrah", "Coimbatore", "Jabalpur",
    "Gwalior", "Vijayawada", "Jodhpur", "Madurai", "Raipur", "Kota", "Guwahati", "Chandigarh", "Solapur", "Hubli-Dharwad",
    "Bareilly", "Moradabad", "Mysore", "Gurgaon", "Aligarh", "Jalandhar", "Tiruchirappalli", "Bhubaneswar", "Salem", "Mira-Bhayandar",
    "Warangal", "Guntur", "Bhiwandi", "Saharanpur", "Gorakhpur", "Bikaner", "Amravati", "Noida", "Jamshedpur", "Bhilai",
    "Cuttack", "Firozabad", "Kochi", "Nellore", "Bhavnagar", "Dehradun", "Durgapur", "Asansol", "Rourkela", "Nanded",
    "Kolhapur", "Ajmer", "Gulbarga", "Jamnagar", "Ujjain", "Loni", "Siliguri", "Jhansi", "Ulhasnagar", "Jammu",
    "Sangli-Miraj & Kupwad", "Belgaum", "Mangalore", "Ambattur", "Tirunelveli", "Malegaon", "Gaya", "Jalgaon", "Udaipur", "Maheshtala"
  ];

  List<String> get _cityList => widget.customCityList ?? _defaultCityList;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _removeOverlay();
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isEmpty) {
        _removeOverlay();
        setState(() => _showDropdown = false);
        return;
      }

      final filtered = _cityList
          .where((city) => city.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _filteredCities = filtered;
        _showDropdown = true;
      });

      _showOverlay();
    });
  }

  void _showOverlay() {
    _removeOverlay();
    
    final overlay = Overlay.of(context);
    if (!mounted) return;
    
    _overlayEntry = _createOverlayEntry();
    if (_overlayEntry != null) {
      overlay.insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry? _createOverlayEntry() {
    if (!mounted) return null;
    final renderObject = context.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return null;
    RenderBox renderBox = renderObject;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: _filteredCities.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("No cities found", style: TextStyle(color: AppColors.muted)),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filteredCities.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredCities[index]),
                          onTap: () {
                            _selectCity(_filteredCities[index]);
                          },
                          hoverColor: AppColors.paleBlue,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          visualDensity: VisualDensity.compact,
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectCity(String city) {
    _controller.text = city;
    _controller.selection = TextSelection.fromPosition(TextPosition(offset: city.length));
    widget.onCitySelected(city);
    _removeOverlay();
    setState(() {
      _showDropdown = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        validator: widget.validator,
        onChanged: _onSearchChanged,
        decoration: AppLayout.commonInputDecoration(hintText: widget.hintText).copyWith(
          prefixIcon: const Icon(Icons.location_city, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLocating)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                IconButton(
                  icon: Icon(Icons.my_location, size: 18, color: AppColors.primaryColor),
                  onPressed: _handleCurrentLocation,
                  tooltip: "Use current location",
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _controller.clear();
                    _onSearchChanged("");
                    setState(() {});
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
