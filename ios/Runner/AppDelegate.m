#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"it.versionestabile.flutterapp000001/single"
                                     binaryMessenger:controller];
    
    [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        
        if ([call.method isEqualToString:@"crash"])
        {
            @throw([NSException
                    exceptionWithName:@"iOS Exception"
                    reason:@"Testing native iOS exceptions"
                    userInfo:nil]);
            
            result(FlutterMethodNotImplemented);
        }
        else
        {
            result(FlutterMethodNotImplemented);
        }
        
    }];
    
    [GeneratedPluginRegistrant registerWithRegistry:self];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
