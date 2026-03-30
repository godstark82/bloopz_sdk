import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'bloopz_referral.dart';

class BloopzReferrer {
  static const MethodChannel _method = MethodChannel('bloopz_sdk/methods');
  static const EventChannel _events = EventChannel('bloopz_sdk/referrer');

  static Stream<BloopzReferral>? _referrals;

  /// Stream of install referrer events (Android only).
  ///
  /// Call this early (e.g. at startup) to capture the first referrer.
  static Stream<BloopzReferral> referrals() {
    _referrals ??= _events.receiveBroadcastStream().map((event) {
      if (event is Map) {
        final raw = (event['rawReferrer'] as String?) ?? '';
        final params = (event['params'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? const <String, String>{};
        return BloopzReferral(rawReferrer: raw, params: params);
      }
      if (event is String) {
        return BloopzReferral(rawReferrer: event, params: _parseQueryParams(event));
      }
      return BloopzReferral(rawReferrer: '', params: const {});
    }).asBroadcastStream();
    return _referrals!;
  }

  /// One-shot read of the current install referrer (Android only).
  ///
  /// Returns `null` when not available or on non-Android platforms.
  static Future<BloopzReferral?> getInstallReferrer() async {
    if (!Platform.isAndroid) return null;
    final result = await _method.invokeMethod<dynamic>('getInstallReferrer');
    if (result == null) return null;
    if (result is Map) {
      final raw = (result['rawReferrer'] as String?) ?? '';
      final params = (result['params'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? const <String, String>{};
      return BloopzReferral(rawReferrer: raw, params: params);
    }
    if (result is String) {
      return BloopzReferral(rawReferrer: result, params: _parseQueryParams(result));
    }
    return null;
  }

  static Map<String, String> _parseQueryParams(String queryLike) {
    final q = queryLike.startsWith('?') ? queryLike.substring(1) : queryLike;
    final out = <String, String>{};
    for (final part in q.split('&')) {
      final idx = part.indexOf('=');
      if (idx <= 0) continue;
      final k = Uri.decodeQueryComponent(part.substring(0, idx));
      final v = Uri.decodeQueryComponent(part.substring(idx + 1));
      out[k] = v;
    }
    return out;
  }
}

