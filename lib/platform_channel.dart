import 'dart:async';

import 'package:flutter/services.dart';

class PlatformChannel {
  static const MethodChannel _methodChannel = const MethodChannel('sample.test.platform/text');
  static const EventChannel _eventChannel = const EventChannel('sample.test.platform/number');
  Stream<int> _onNumberChanged;

  /// MethodChannel com.test.platform/text
  Future<String> getStringReturnFromPlatform(String text) async {
    return await _methodChannel.invokeMethod<String>(
        'sendtext', {'message': text});
  }

  /// EventChannel com.test.platform/number
  Stream<int> get  getTimerStream => _eventChannel.receiveBroadcastStream().map((dynamic event) => event as int);

}
