/*
 * @Author: kevin
 * @Date: 2020-09-25 17:42:49
 * @LastEditTime: 2020-09-29 15:34:28
 * @Description: flutter
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

typedef Future<dynamic> EventHandler(Map<String, dynamic> event);

class FlutterGtPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_gt_plugin');

  ///获取clientId
  static EventHandler _getClientId;

  ///点击通知时回传通知消息内容
  static EventHandler _onOpenNotification;
  static EventHandler _onReceiveMessage;

  static Future<dynamic> _handleMethod(MethodCall call) async {
    String method = call.method;
    switch (method) {
      case 'onReceiveClientId':
        return _getClientId(call.arguments.cast<String, dynamic>());
        break;
      case 'onOpenNotification':
        return _onOpenNotification(call.arguments.cast<String, dynamic>());
        break;
      case 'onReceiveMessage':
        return _onReceiveMessage(call.arguments.cast<String, dynamic>());
        break;
    }
  }

  ///添加事件监听
  static void addEventHandler(
      {EventHandler getClientId,
      EventHandler onOpenNotification,
      EventHandler onReceiveMessage}) {
    _getClientId = getClientId;
    _onOpenNotification = onOpenNotification;
    _onReceiveMessage = onReceiveMessage;
  }

  ///设置iOS角标
  ///badgeNumber 角标数

  static setBadgeNumber({num badgeNumber}) {
    if (Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethod);
      _channel.invokeMethod('setBadgeNumber', {
        'badgeNumber': badgeNumber,
      });
    }
  }

  ///启动个推sdk
  ///appId 个推appId
  ///appKey 个推appKey
  ///appSecret 个推appSecret
  static setup({
    String appId,
    String appKey,
    String appSecret,
  }) {
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod('setup', {
      'appKey': appKey,
      'appId': appId,
      'appSecret': appSecret,
    });
  }

  ///请求通知权限
  static applyPushAuthority() {
    _channel.invokeMethod('applyPushAuthority');
  }
}
