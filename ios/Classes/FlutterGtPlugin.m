#import "FlutterGtPlugin.h"
#import <GTSDK/GeTuiSdk.h>
#import <UserNotifications/UserNotifications.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@interface FlutterGtPlugin()<UIApplicationDelegate, GeTuiSdkDelegate, UNUserNotificationCenterDelegate>

@end

@implementation FlutterGtPlugin{
  NSDictionary *_launchNotification;
  NSDictionary *_completeLaunchNotification;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
                                   methodChannelWithName:@"flutter_gt_plugin"
                                   binaryMessenger:[registrar messenger]];
  FlutterGtPlugin* instance = [[FlutterGtPlugin alloc] init];
  instance.channel = channel;
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"setup" isEqualToString:call.method]){
    [self setup:call result:result];
  }else if([@"applyPushAuthority" isEqualToString:call.method]){
    [self applyPushAuthority:call result:result];
  }else if([@"setBadgeNumber" isEqualToString:call.method]){
//      [self applyPushAuthority:call result:result];
      NSNumber *badgeNumber = call.arguments[@"badgeNumber"];
      [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber.integerValue;
    }else{
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  _completeLaunchNotification = launchOptions;
  if (launchOptions != nil) {
    // NSLog(launchOptions);
    _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  }
//  _isPush = YES;
//  application.applicationIconBadgeNumber = 0;
  return YES;
}
/// 请求通知权限
- (void)registerRemoteNotification {
  float iOSVersion = [[UIDevice currentDevice].systemVersion floatValue];
  if (iOSVersion >= 10.0) {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
      if (!error && granted) {
        
      }
    }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    return;
  }
  
  if (iOSVersion >= 8.0) {
    UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
  }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  //  _resumingFromBackground = YES;
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
  //
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [GeTuiSdk registerDeviceTokenData:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
  // 将收到的APNs信息传给个推统计
  [GeTuiSdk handleRemoteNotification:userInfo];
//  _isPush = YES;
    NSDictionary *dic;
    if ([userInfo[@"payload"] isKindOfClass:[NSString class]]) {
      NSData *jsonData = [userInfo[@"payload"] dataUsingEncoding:NSUTF8StringEncoding];
      dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }else{
      dic = userInfo[@"payload"];
    }
    
    [self.channel invokeMethod:@"onOpenNotification" arguments:dic];
  completionHandler(UIBackgroundFetchResultNewData);
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  NSDictionary *dic;
  if ([notification.userInfo[@"payload"] isKindOfClass:[NSString class]]) {
    NSData *jsonData = [notification.userInfo[@"payload"] dataUsingEncoding:NSUTF8StringEncoding];
    dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
  }else{
    dic = notification.userInfo[@"payload"];
  }
  
  [self.channel invokeMethod:@"onOpenNotification" arguments:dic];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
  // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
  completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  // [ GTSdk ]：将收到的APNs信息传给个推统计
  [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
  if (![response.notification.request.content.userInfo.allKeys containsObject:@"payload"]){
    return;
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    NSDictionary *dic = @{};
    if ([response.notification.request.content.userInfo[@"payload"] isKindOfClass:[NSDictionary class]]) {
        dic = response.notification.request.content.userInfo[@"payload"];
    }else{
        NSData *jsonData = [response.notification.request.content.userInfo[@"payload"] dataUsingEncoding:NSUTF8StringEncoding];
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    }
      [self.channel invokeMethod:@"onOpenNotification" arguments:dic];
  });
  completionHandler();
}

#endif
/// 个推注册后返回clientId的代理方法
/// @param clientId 个推设备标识符
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
  [_channel invokeMethod:@"onReceiveClientId" arguments:@{@"clientId":clientId}];

}
/// 个推透传消息代理方法
/// @param payloadData 透传消息内容
/// @param taskId 透传消息taskId
/// @param msgId 透传消息msgId
/// @param offLine 是否离线状态
/// @param appId 个推appId
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:payloadData options:NSJSONReadingMutableContainers error:nil];
  if (!offLine) {
    if ([dict.allKeys containsObject:@"title"]&&[dict.allKeys containsObject:@"text"]) {
      [self addLocalNotificationWithTitle:dict[@"title"] Body:dict[@"text"] userInfo:@{@"payload":dict}];
    }
  }
}
/// 启动个推SDK
/// @param call 个推参数 appid 个推appId appKey 、个推appKey、appSecret，个推appSecret 从个推网站   delegate获取回调代理delegate
/// @param result result description
- (void)setup:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;
  [GeTuiSdk startSdkWithAppId:arguments[@"appId"] appKey:arguments[@"appKey"] appSecret:arguments[@"appSecret"] delegate:self];
}
/// 请求通知权限
/// @param call call description
/// @param result result description
- (void)applyPushAuthority:(FlutterMethodCall*)call result:(FlutterResult)result {
  [self registerRemoteNotification];
}


#pragma mark 添加本地通知
/// 添加本地通知
/// @param title 通知alertTitle
/// @param alertBody 通知alertBody
-(void)addLocalNotificationWithTitle:(NSString *)title Body:(NSString *)alertBody userInfo:(NSDictionary *)userInfo{
  if (@available(iOS 10.0, *)) {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.badge = @1;
    content.title = title;
    content.body = alertBody;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = userInfo;
    // 通知触发器
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:false];
    NSString *identifier = [NSString stringWithFormat:@"%@",[NSDate dateWithTimeIntervalSince1970:0]];
    // 通知请求
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    //添加通知
    [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
      NSLog(@"error:%@",error);
    }];
  } else {
    //定义本地通知对象
    UILocalNotification *notification=[[UILocalNotification alloc]init];
    //设置调用时间
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:10.0];//通知触发的时间，10s以后
    //设置通知属性
    notification.alertTitle = title;
    notification.alertBody= alertBody; //通知主体
    notification.userInfo = userInfo;
//    notification.applicationIconBadgeNumber=1;//应用程序图标右上角显示的消息数
    notification.soundName=UILocalNotificationDefaultSoundName;//收到通知时播放的声音，默认消息声音
    //调用通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
  }
  
}
@end
