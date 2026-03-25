import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_app/core/theme/app_colors.dart';
import 'package:flutter_app/core/theme/app_text_styles.dart';
import 'package:flutter_app/shared/models/worker.dart';
import 'package:flutter_app/shared/widgets/primary_button.dart';
import 'package:flutter_app/features/booking/providers/booking_providers.dart';
import 'package:flutter_app/features/booking/presentation/booking_success_screen.dart';
import 'package:flutter_app/core/services/location_service.dart';
import 'package:flutter_app/core/utils/api_error_handler.dart';
import 'package:geolocator/geolocator.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Worker worker;

  const BookingScreen({super.key, required this.worker});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final TextEditingController _addressController = TextEditingController(text: "B-42, Sector 18, Noida, UP 201301");
  final int _hours = 4;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;
  final LocationService _locationService = LocationService();

  final List<String> _timeSlots = [
    "07:00 AM", "09:00 AM", "10:00 AM", "11:30 AM",
    "12:00 PM", "02:00 PM", "04:00 PM", "06:00 PM"
  ];

  Future<void> _handleBooking() async {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a time slot")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repository = ref.read(bookingRepositoryProvider);
      final booking = await repository.createBooking(
        workerId: widget.worker.id,
        categoryId: widget.worker.categories.isNotEmpty ? widget.worker.categories.first.id : 0,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        timeSlot: _selectedTime!,
        hours: _hours,
        address: _addressController.text,
      );

      ref.invalidate(bookingsProvider);
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingSuccessScreen(
              workerName: widget.worker.name,
              date: DateFormat('MMM dd, yyyy').format(_selectedDate),
              time: _selectedTime!,
              reference: booking.bookingRef,
              message: booking.message,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorHandler.getErrorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Book ${widget.worker.name}", style: AppTextStyles.h3),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _buildProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("📅 Select Date"),
                        const SizedBox(height: 16),
                        _buildDatePicker(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("🕐 Select Time"),
                        const SizedBox(height: 16),
                        _buildTimeGrid(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("📍 Your Address", icon: Icons.favorite, iconColor: Colors.pinkAccent),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.paleBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _addressController,
                            maxLines: 2,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildLocationRow(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("👷 Your Worker", icon: Icons.person, iconColor: Colors.orangeAccent),
                        const SizedBox(height: 16),
                        _buildWorkerMiniCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("💰 Price Summary", icon: Icons.monetization_on, iconColor: Colors.orange),
                        const SizedBox(height: 16),
                        _buildPriceSummary(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: "Confirm Booking →", 
                    isLoading: _isSubmitting,
                    onPressed: _handleBooking,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStep(1, "Worker", true, isCheck: true),
        _buildLine(true),
        _buildStep(2, "Schedule", true, isCurrent: true),
        _buildLine(false),
        _buildStep(3, "Address", false),
        _buildLine(false),
        _buildStep(4, "Pay", false),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isCompleted, {bool isCurrent = false, bool isCheck = false}) {
    return Column(
      children: [
        Container(
          height: 32,
          width: 32,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primaryColor : AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: isCompleted ? AppColors.primaryColor : AppColors.border, width: 2),
          ),
          alignment: Alignment.center,
          child: isCheck
              ? const Icon(Icons.check, color: AppColors.white, size: 18)
              : Text(step.toString(), style: AppTextStyles.bodySmall.copyWith(
                  color: isCompleted ? AppColors.white : AppColors.muted,
                  fontWeight: FontWeight.bold,
                )),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.bodySmall.copyWith(
          fontSize: 10, 
          color: isCurrent ? AppColors.primaryColor : AppColors.muted,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        )),
      ],
    );
  }

  Widget _buildLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        color: isActive ? AppColors.primaryColor : AppColors.border,
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon, Color? iconColor}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
        ],
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
      ],
    );
  }

  Widget _buildDatePicker() {
    final List<DateTime> dates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
    
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 48,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date), 
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? AppColors.white : AppColors.muted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    )),
                  Text(DateFormat('d').format(date), 
                    style: AppTextStyles.h3.copyWith(
                      color: isSelected ? AppColors.white : AppColors.text,
                      fontSize: 16,
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 2.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final slot = _timeSlots[index];
        final isSelected = _selectedTime == slot;

        return GestureDetector(
          onTap: () => setState(() => _selectedTime = slot),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppColors.primaryColor : AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              slot,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.muted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        String? address = await _locationService.getAddressFromLatLng(position);
        if (address != null) {
          setState(() {
            _addressController.text = address;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not fetch location: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Icon(
          _isFetchingLocation ? Icons.hourglass_empty : Icons.explore_outlined,
          color: AppColors.primaryColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
          child: Text(
            _isFetchingLocation ? "Fetching location..." : "Use my current location",
            style: AppTextStyles.label.copyWith(
              fontSize: 12,
              color: _isFetchingLocation ? AppColors.muted : AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerMiniCard() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.paleBlue,
          child: Text(widget.worker.categories.isNotEmpty ? widget.worker.categories.first.emoji : "👷", style: const TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.worker.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              Text(widget.worker.categories.isNotEmpty ? widget.worker.categories.first.name : "Professional", style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.orangeWarning, size: 12),
                  const Icon(Icons.star, color: AppColors.orangeWarning, size: 12),
                  const Icon(Icons.star, color: AppColors.orangeWarning, size: 12),
                  const Icon(Icons.star, color: AppColors.orangeWarning, size: 12),
                  const Icon(Icons.star, color: AppColors.orangeWarning, size: 12),
                  const SizedBox(width: 4),
                  Text("${widget.worker.rating} (128 reviews)", style: AppTextStyles.bodySmall.copyWith(fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("Change", style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    final basePrice = widget.worker.hourlyRate * _hours;
    const platformFee = 50.0;
    final discount = (basePrice * 0.2); // 20% first booking discount
    final total = basePrice + platformFee - discount;

    return Column(
      children: [
        _buildPriceRow("Rate (₹${widget.worker.hourlyRate.toInt()} × $_hours hrs)", "₹${basePrice.toInt()}"),
        const SizedBox(height: 12),
        _buildPriceRow("Platform fee", "₹$platformFee"),
        const SizedBox(height: 12),
        _buildPriceRow("First booking discount", "- ₹${discount.toInt()}", isDiscount: true),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Divider(color: AppColors.border.withOpacity(0.5)),
        ),
        _buildPriceRow("Total", "₹${total.toInt()}", isBold: true),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    final style = isBold 
        ? AppTextStyles.h3.copyWith(fontSize: 18) 
        : AppTextStyles.bodyMedium.copyWith(color: AppColors.muted, fontSize: 14);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value, 
          style: style.copyWith(
            color: isDiscount ? AppColors.successGreen : AppColors.text,
            fontWeight: isBold || isDiscount ? FontWeight.bold : FontWeight.normal,
          )
        ),
      ],
    );
  }
}
