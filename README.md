
# react-native-user-notification
**UNDER DEVELOPMENT**

## TODO LIST
1. Package up as react-native library
2. Publish NPM package
3. Add Installation Instruction
4. Add Usage Documentation

This package provides react-native javascript support to new IOS user notification API introduced in IOS 10.
Please use this library only if you want to support advanced notification API in your react-native app. For older API use the RNPushNotification package from react-native.

## Getting started
You will just need these two steps to pull in the library:

`$ npm install react-native-user-notification --save`
`$ react-native link react-native-user-notification`

If you prefer do it manually, here is what you should do:

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-user-notification` and add `RNUserNotification.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNUserNotification.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### AppDelegate Modifications
Next step is to include following code in app delegate:

1. Add the following code to your AppDelegate.h file
This will make app delegate an UNUserNotificationDelegate as well.
```objc
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
...
...
@end
```
2. Add the following code to your AppDelegate.m file
```objc
#import "RNUserNotificationEvents.h"

@implementation AppDelegate {
    RNUserNotificationEvent* eventManager;
}

// other existing code

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  eventManager = [ RNUserNotificationEvent shared];
  
  // rest of the stuff goes below
  //
  //
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
  
  //Called when a notification is delivered to a foreground app.

  
  NSLog(@"AD PUSH Userinfo %@",notification.request.content.userInfo);

  [eventManager postEvent:RNUN_EV_RECEIVED_NOTIFICATION userInfo:@{@"notification": notification}];
  completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
  //Called to let your app know which action was selected by the user for a given notification.
  NSLog(@"AD PUSH Userinfo %@",response.notification.request.content.userInfo);
  [eventManager postEvent:RNUN_EV_RECEIVED_NOTIFICATION_RESPONSE userInfo:@{@"response": response}];
  completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);
}

/* IOS 9 COMPATIBLE APIS */

// Permission Request Notification - on IOS 9
// This Will Trigger registerForRemoteNotification on IOS 9
// ON IOS 10 You get a Completion Handler after which you can call registerForRemoteNotifications
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
  [eventManager postEvent:RNUN_EV_SUCCESS_USER_NOTIFICATION_SETTINGS userInfo:@{@"settings": notificationSettings}];
}

// Remote Notification Registration - SUCCESS
// INVOKED ON BOTH IOS 9 & IOS 10
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  NSLog(@"AD PUSH Reg Success: %@", deviceToken);

  [eventManager postEvent:RNUN_EV_SUCCESS_REMOTE_NOTIFICATION_REG userInfo:@{@"deviceToken": deviceToken}];
}

// Remote Notification Registration - FAILURE
// INVOKED ON BOTH IOS 9 & IOS 10
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  NSLog(@"AD PUSH Reg Error: %@", error);

  [eventManager postEvent:RNUN_EV_FAILURE_REMOTE_NOTIFICATION_REG userInfo:@{@"error": error}];
}

// Required for the notification event.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
{
  [eventManager postEvent:RNUN_EV_RECEIVED_REMOTE_NOTIFICATION userInfo:@{@"notification": notification}];
}

// Required for the localNotification event.
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  [eventManager postEvent:RNUN_EV_RECEIVED_LOCAL_NOTIFICATION userInfo:@{@"notification": notification}];
}

```

## Usage
```javascript
import RNUserNotification from 'react-native-user-notification';

// TODO: What to do with the module?
RNUserNotification;
```
  
