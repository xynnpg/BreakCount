import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/constants.dart';
import '../app/routes.dart';
import '../services/storage_service.dart';
import '../services/school_data_service.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() =>
      _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedCountry;
  bool _isLoading = false;
  String? _error;

  List<Map<String, String>> get _filtered {
    if (_query.isEmpty) return allCountries;
    final q = _query.toLowerCase();
    return allCountries
        .where((c) => c['name']!.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestAppPermissions() async {
    await [
      Permission.notification,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
      Permission.nearbyWifiDevices,
    ].request();
  }

  Future<void> _confirm(BuildContext context) async {
    if (_selectedCountry == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final navigator = Navigator.of(context);
    await _requestAppPermissions();
    final schoolYear =
        await SchoolDataService.fetchAndCache(_selectedCountry!);

    if (!mounted) return;

    if (schoolYear == null) {
      setState(() {
        _isLoading = false;
        _error = 'Could not load school data. Check your connection.';
      });
      return;
    }

    await StorageService.saveString(
        StorageKeys.selectedCountry, _selectedCountry!);

    navigator.pushReplacementNamed(
        Routes.profileSelection, arguments: _selectedCountry!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildGrid()),
            if (_error != null) _buildError(),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Country',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'We\'ll fetch your school calendar once and cache it offline.',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        style: GoogleFonts.outfit(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search country...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textTertiary, size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final filtered = _filtered;
    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No countries found',
          style: GoogleFonts.outfit(color: AppColors.textTertiary),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final country = filtered[index];
        final isSelected = _selectedCountry == country['name'];
        return _CountryTile(
          name: country['name']!,
          flag: country['flag']!,
          selected: isSelected,
          onTap: () => setState(() => _selectedCountry = country['name']),
        );
      },
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Text(
        _error!,
        style: GoogleFonts.outfit(color: AppColors.error, fontSize: 13),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _selectedCountry != null && !_isLoading
              ? () => _confirm(context)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.surfaceBorder,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _selectedCountry != null
                      ? 'Continue with $_selectedCountry'
                      : 'Select a country',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedCountry != null
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  final String name;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  const _CountryTile({
    required this.name,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      selected ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
