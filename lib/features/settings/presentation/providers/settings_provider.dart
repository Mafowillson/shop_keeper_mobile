import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopkeeper/core/constants/app_strings.dart';
import 'package:shopkeeper/core/network/dio_client.dart';

// ── Notification preferences model ────────────────────────────────────────────

class NotificationPrefs {
  final bool lowStock;
  final bool largeSale;
  final bool debtPayment;
  final bool staffLogin;
  final double largeSaleThreshold;

  const NotificationPrefs({
    this.lowStock = true,
    this.largeSale = true,
    this.debtPayment = true,
    this.staffLogin = true,
    this.largeSaleThreshold = 50000,
  });

  factory NotificationPrefs.fromJson(Map<String, dynamic> json) =>
      NotificationPrefs(
        lowStock: json['low_stock'] as bool? ?? true,
        largeSale: json['large_sale'] as bool? ?? true,
        debtPayment: json['debt_payment'] as bool? ?? true,
        staffLogin: json['staff_login'] as bool? ?? true,
        largeSaleThreshold:
            (json['large_sale_threshold'] as num?)?.toDouble() ?? 50000,
      );

  Map<String, dynamic> toJson() => {
        'low_stock': lowStock,
        'large_sale': largeSale,
        'debt_payment': debtPayment,
        'staff_login': staffLogin,
        'large_sale_threshold': largeSaleThreshold,
      };

  NotificationPrefs copyWith({
    bool? lowStock,
    bool? largeSale,
    bool? debtPayment,
    bool? staffLogin,
    double? largeSaleThreshold,
  }) =>
      NotificationPrefs(
        lowStock: lowStock ?? this.lowStock,
        largeSale: largeSale ?? this.largeSale,
        debtPayment: debtPayment ?? this.debtPayment,
        staffLogin: staffLogin ?? this.staffLogin,
        largeSaleThreshold: largeSaleThreshold ?? this.largeSaleThreshold,
      );
}

// ── Provider ──────────────────────────────────────────────────────────────────

class SettingsProvider extends ChangeNotifier {
  static const _keyLanguage = AppStrings.languagePreferenceKey;

  final Dio _dio;

  // ── Local settings ─────────────────────────────────────────────────────────
  bool _initialized = false;
  String?
      _language; // null = follow device locale; 'en' | 'fr' = explicit choice

  // ── Owner notification preferences ────────────────────────────────────────
  NotificationPrefs _notifPrefs = const NotificationPrefs();
  bool _isLoadingPrefs = false;
  bool _isSavingPrefs = false;
  String? _prefsError;

  SettingsProvider(DioClient dioClient) : _dio = dioClient.client;

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get initialized => _initialized;
  String? get language => _language;
  bool get isFrench => _language == 'fr';
  NotificationPrefs get notifPrefs => _notifPrefs;
  bool get isLoadingPrefs => _isLoadingPrefs;
  bool get isSavingPrefs => _isSavingPrefs;
  String? get prefsError => _prefsError;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_keyLanguage); // null when user never chose
    _initialized = true;
    notifyListeners();
  }

  // ── Local settings ─────────────────────────────────────────────────────────

  Future<void> setLanguage(String lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, lang);
  }

  // ── Owner notification preferences ────────────────────────────────────────

  Future<void> loadNotificationPrefs() async {
    _isLoadingPrefs = true;
    _prefsError = null;
    notifyListeners();
    try {
      final res = await _dio.get('/notifications/preferences');
      _notifPrefs =
          NotificationPrefs.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      _prefsError = 'Could not load notification preferences.';
    } finally {
      _isLoadingPrefs = false;
      notifyListeners();
    }
  }

  Future<void> _updatePrefs(NotificationPrefs updated) async {
    final previous = _notifPrefs;
    _notifPrefs = updated; // optimistic update
    _prefsError = null;
    notifyListeners();
    try {
      _isSavingPrefs = true;
      notifyListeners();
      await _dio.put('/notifications/preferences', data: updated.toJson());
    } catch (_) {
      _notifPrefs = previous; // rollback
      _prefsError = 'Failed to save — please try again.';
    } finally {
      _isSavingPrefs = false;
      notifyListeners();
    }
  }

  Future<void> toggleLowStock() =>
      _updatePrefs(_notifPrefs.copyWith(lowStock: !_notifPrefs.lowStock));

  Future<void> toggleLargeSale() =>
      _updatePrefs(_notifPrefs.copyWith(largeSale: !_notifPrefs.largeSale));

  Future<void> toggleDebtPayment() =>
      _updatePrefs(_notifPrefs.copyWith(debtPayment: !_notifPrefs.debtPayment));

  Future<void> toggleStaffLogin() =>
      _updatePrefs(_notifPrefs.copyWith(staffLogin: !_notifPrefs.staffLogin));

  Future<void> setLargeSaleThreshold(double value) =>
      _updatePrefs(_notifPrefs.copyWith(largeSaleThreshold: value));

  void clearError() {
    _prefsError = null;
    notifyListeners();
  }
}
