#import <Flutter/Flutter.h>

API_AVAILABLE(ios(10.0))
@interface FlutterGtPlugin : NSObject<FlutterPlugin>
@property FlutterMethodChannel *channel;
@end
