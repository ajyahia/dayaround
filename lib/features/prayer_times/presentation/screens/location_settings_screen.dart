import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jimy/features/prayer_times/data/cities_data.dart';
import 'package:jimy/features/prayer_times/domain/models/app_location.dart';
import 'package:jimy/features/prayer_times/presentation/controllers/prayer_times_providers.dart';

class LocationSettingsScreen extends ConsumerStatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  ConsumerState<LocationSettingsScreen> createState() =>
      _LocationSettingsScreenState();
}

class _LocationSettingsScreenState
    extends ConsumerState<LocationSettingsScreen> {
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(currentLocationProvider);
    _latController = TextEditingController(
      text: current.latitude.toStringAsFixed(4),
    );
    _lngController = TextEditingController(
      text: current.longitude.toStringAsFixed(4),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleAutoLocation() async {
    setState(() => _isDetecting = true);
    final success = await ref
        .read(currentLocationProvider.notifier)
        .detectAutoLocation();
    setState(() => _isDetecting = false);

    if (!mounted) return;

    if (!success) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('تعذر تحديد الموقع تلقائياً'),
          content: const Text(
            'يرجى التأكد من تفعيل خدمة تحديد الموقع وإعطاء الإذن للتطبيق، أو اختر مدينتك يدويًا من القائمة أدناه.',
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
    }
  }

  void _saveCustomCoordinates() {
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());

    if (lat == null || lng == null || lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('إحداثيات غير صحيحة'),
          content: const Text('يرجى إدخال خط عرض بين -90 و 90 وخط طول بين -180 و 180.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
      return;
    }

    final newLoc = AppLocation(
      name: 'إحداثيات مخصصة',
      latitude: lat,
      longitude: lng,
      isAuto: false,
    );
    ref.read(currentLocationProvider.notifier).setLocation(newLoc);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(currentLocationProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'الإعدادات',
        middle: Text('الموقع الجغرافي'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            // Auto GPS Section
            CupertinoListSection.insetGrouped(
              header: const Text('التحديد التلقائي'),
              footer: const Text(
                'يُستخدم موقعك الجغرافي لحساب أوقات الصلاة على جهازك محلياً فقط دون مشاركة أي بيانات.',
              ),
              children: [
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.location_fill,
                    color: CupertinoColors.systemBlue,
                  ),
                  title: const Text('تحديد الموقع تلقائياً (GPS)'),
                  trailing: _isDetecting
                      ? const CupertinoActivityIndicator()
                      : (currentLocation.isAuto
                          ? const Icon(
                              CupertinoIcons.checkmark,
                              color: CupertinoColors.systemBlue,
                            )
                          : null),
                  onTap: _isDetecting ? null : _handleAutoLocation,
                ),
              ],
            ),

            // Predefined Cities List
            CupertinoListSection.insetGrouped(
              header: const Text('المدن المدعومة'),
              children: kPredefinedCities.map((city) {
                final isSelected = !currentLocation.isAuto &&
                    (currentLocation.name == city.arabicName ||
                        ((currentLocation.latitude - city.latitude).abs() < 0.01 &&
                            (currentLocation.longitude - city.longitude).abs() < 0.01));

                return CupertinoListTile(
                  title: Text(city.arabicName),
                  subtitle: Text(city.englishName),
                  trailing: isSelected
                      ? const Icon(
                          CupertinoIcons.checkmark,
                          color: CupertinoColors.systemBlue,
                        )
                      : null,
                  onTap: () {
                    final newLoc = AppLocation(
                      name: city.arabicName,
                      latitude: city.latitude,
                      longitude: city.longitude,
                      isAuto: false,
                    );
                    ref
                        .read(currentLocationProvider.notifier)
                        .setLocation(newLoc);
                  },
                );
              }).toList(),
            ),

            // Manual Coordinates Section
            CupertinoListSection.insetGrouped(
              header: const Text('إدخال إحداثيات مخصصة يدويًا'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 70,
                        child: Text('خط العرض:'),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _latController,
                          placeholder: '30.0444',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 70,
                        child: Text('خط الطول:'),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _lngController,
                          placeholder: '31.2357',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CupertinoListTile(
                  title: const Text(
                    'حفظ الإحداثيات المخصصة',
                    style: TextStyle(color: CupertinoColors.systemBlue),
                  ),
                  onTap: _saveCustomCoordinates,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
