import 'package:flutter/services.dart';
import 'package:purchases_flutter/models/offering_wrapper.dart';

import 'paywall_result.dart';
import 'paywall_view_mode.dart';

export 'paywall_result.dart';

class RevenueCatUI {
  static const _methodChannel = MethodChannel('purchases_ui_flutter');

  /// Presents the paywall as an activity on android or a modal in iOS.
  /// Returns a [PaywallResult] indicating the result of the paywall presentation.
  /// @param [offering] If set, will present the paywall associated to the given Offering.
  /// @param [displayCloseButton] Optionally present the paywall with a close button.
  static Future<PaywallResult> presentPaywall({
    Offering? offering,
    bool displayCloseButton = false,
    PaywallViewMode? viewMode,
  }) async {
    final result = await _methodChannel.invokeMethod('presentPaywall', {
      'offeringIdentifier': offering?.identifier,
      'displayCloseButton': displayCloseButton,
      'paywallViewMode': _parseViewModeToString(viewMode),
    });
    return _parseStringToResult(result);
  }

  /// Presents the paywall as an activity on android or a modal in iOS as long
  /// as the user does not have the given entitlement identifier active.
  /// Returns a [PaywallResult] indicating the result of the paywall presentation.
  ///
  /// @param [requiredEntitlementIdentifier] Entitlement identifier to check if the user has access to before presenting the paywall.
  /// @param [offering] If set, will present the paywall associated to the given Offering.
  /// @param [displayCloseButton] Optionally present the paywall with a close button.
  static Future<PaywallResult> presentPaywallIfNeeded(
    String requiredEntitlementIdentifier, {
    Offering? offering,
    bool displayCloseButton = false,
    PaywallViewMode? viewMode,
  }) async {
    final result = await _methodChannel.invokeMethod(
      'presentPaywallIfNeeded',
      {
        'requiredEntitlementIdentifier': requiredEntitlementIdentifier,
        'offeringIdentifier': offering?.identifier,
        'paywallViewMode': _parseViewModeToString(viewMode),
      },
    );
    return _parseStringToResult(result);
  }

  static PaywallResult _parseStringToResult(String paywallResultString) {
    switch (paywallResultString) {
      case 'NOT_PRESENTED':
        return PaywallResult.notPresented;
      case 'CANCELLED':
        return PaywallResult.cancelled;
      case 'ERROR':
        return PaywallResult.error;
      case 'PURCHASED':
        return PaywallResult.purchased;
      case 'RESTORED':
        return PaywallResult.restored;
      default:
        return PaywallResult.error;
    }
  }

  static String _parseViewModeToString(PaywallViewMode? viewMode) {
    switch (viewMode) {
      case PaywallViewMode.footer:
        return 'footer';
      case PaywallViewMode.condensed:
        return 'condensed';
      case PaywallViewMode.fullscreen:
      default:
        return 'full_screen';
    }
  }
}
