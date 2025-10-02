import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../payment/payment_screen.dart';

class CargoSelectionDialog extends StatefulWidget {
  const CargoSelectionDialog({super.key});

  @override
  State<CargoSelectionDialog> createState() => _CargoSelectionDialogState();
}

class _CargoSelectionDialogState extends State<CargoSelectionDialog> {
  final TextEditingController _weightController = TextEditingController();
  final List<String> _selectedCargoTypes = [];

  final List<Map<String, dynamic>> _cargoTypes = [
    {
      'id': 'industrial',
      'name': 'Industrial Goods',
      'icon': Icons.precision_manufacturing,
      'color': Colors.blue,
    },
    {
      'id': 'vegetables',
      'name': 'Vegetables & Fruits',
      'icon': Icons.local_grocery_store,
      'color': Colors.green,
    },
    {
      'id': 'household',
      'name': 'Household Items',
      'icon': Icons.home,
      'color': Colors.brown,
    },
    {
      'id': 'fragile',
      'name': 'Fragile Goods',
      'icon': Icons.warning,
      'color': Colors.red,
    },
  ];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.primaryYellow,
                      size: 24,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Select cargo type',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),

            // Cargo Type Selection
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cargoTypes.length,
                itemBuilder: (context, index) {
                  final cargoType = _cargoTypes[index];
                  final isSelected = _selectedCargoTypes.contains(
                    cargoType['id'],
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryYellow
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkBackground
                              : cargoType['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          cargoType['icon'],
                          color: isSelected
                              ? AppColors.primaryYellow
                              : cargoType['color'],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        cargoType['name'],
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.darkBackground
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.darkBackground
                                : Colors.grey,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.darkBackground
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: AppColors.primaryYellow,
                                size: 16,
                              )
                            : null,
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCargoTypes.remove(cargoType['id']);
                          } else {
                            _selectedCargoTypes.add(cargoType['id']);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Weight Input Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Enter cargo weight',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter weight in kg',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        suffixText: 'kg',
                        suffixStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Next Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _selectedCargoTypes.isNotEmpty &&
                              _weightController.text.isNotEmpty
                          ? () => _handleNext()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBackground,
                        foregroundColor: AppColors.primaryYellow,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_selectedCargoTypes.isNotEmpty && _weightController.text.isNotEmpty) {
      // Close dialog first
      Navigator.pop(context);

      // Navigate to payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            bookingData: {
              'cargoTypes': _selectedCargoTypes,
              'weight': _weightController.text,
              'crn': 'BK171000192',
              'amount': '276.66',
            },
          ),
        ),
      );
    }
  }
}
