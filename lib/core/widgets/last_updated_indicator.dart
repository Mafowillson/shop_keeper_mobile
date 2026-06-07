import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shopkeeper/core/cache/cache_metadata_service.dart';
import 'package:shopkeeper/core/constants/app_text_styles.dart';

/// Shows a small "Last updated X minutes ago" line at the bottom of list
/// screens.  Hidden when data is less than 1 minute old or when no timestamp
/// exists.  Ticks every 30 seconds so the label stays current.
class LastUpdatedIndicator extends StatefulWidget {
  /// The Hive box name whose timestamp is displayed.
  final String boxName;
  final CacheMetadataService metadata;

  const LastUpdatedIndicator({
    super.key,
    required this.boxName,
    required this.metadata,
  });

  @override
  State<LastUpdatedIndicator> createState() => _LastUpdatedIndicatorState();
}

class _LastUpdatedIndicatorState extends State<LastUpdatedIndicator> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _label(BuildContext context) {
    final age = widget.metadata.getAge(widget.boxName);
    if (age == null) return '';

    final locale = Localizations.localeOf(context).languageCode;
    final isFr = locale == 'fr';

    final minutes = age.inMinutes;
    if (minutes < 1) return '';

    if (minutes < 60) {
      return isFr
          ? 'Mis à jour il y a $minutes min'
          : 'Last updated $minutes min ago';
    }
    final hours = age.inHours;
    return isFr ? 'Mis à jour il y a $hours h' : 'Last updated ${hours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final label = _label(context);
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyS.copyWith(color: Colors.grey[500]),
      ),
    );
  }
}
