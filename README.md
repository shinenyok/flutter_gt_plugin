<!--
 * @Author: kevin
 * @Date: 2020-09-25 17:19:31
 * @LastEditTime: 2020-09-29 17:34:02
 * @Description: 配置说明
-->
# flutter_gt_plugin

个推iOS、Android插件 目前功能 通知、透传消息以及获取clientId

## Getting Started

在工程 pubspec.yaml 中加入 dependencies
  flutter_gt_plugin:
    git: https://github.com/shinenyok/flutter_gt_plugin.git

## 配置
### iOS:
- 在 xcode8 之后需要点开推送选项： TARGETS -> Capabilities -> Push Notification 设为 on 状态

### Android
- 注册app成功以后分别拿到appId、appKey、appSecret,在android/app目录下的build.gradle 文件中配置如下代码
```
        manifestPlaceholders = [
                GETUI_APP_ID    : "appId",
                GETUI_APP_KEY   : "appKey",
                GETUI_APP_SECRET: "appSecret",
        ]
```

### 使用

```dart
import 'package:flutter_gt_plugin/flutter_gt_plugin.dart';
```
**注意：addEventHandler 方法建议放到 setup 之前，其他方法需要在 setup 方法之后调用**
####  addEventHandler
添加事件监听方法。

```
dart
FlutterGtPlugin.addEventHandler(
    //接收clientId回调方法
    getClientId: (Map<String, dynamic> message) async {
       print("flutter getClientId: ${message['clientId']}");
     }, 
     //点击通知回调方法
     onOpenNotification: (Map<String, dynamic> message) async {
       print("flutter onOpenNotification: $message");
     });
```
### setup

添加初始化方法，调用setup方法会执行两个操作

- 初始化个推SDK
- 将缓存事件下发到dart环境中
```
dart
FlutterGtPlugin.setup(
        appId: '替换成自己的 appId',
        appKey: '替换成自己的 appKey',
        appSecret: '替换成自己的 appSecret');
```

### applyPushAuthority
申请推送权限，注意这个方法只会向用户弹出一次推送权限请求（如果用户不同意，之后只能用户到设置页面里面勾选相应权限），需要开发者选择合适的时机调用。
```
dart
    FlutterGtPlugin.applyPushAuthority();
```
