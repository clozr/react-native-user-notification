
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

1. Add notification event instance
```objc
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

```

## Usage
```javascript
import RNUserNotification from 'react-native-user-notification';

// TODO: What to do with the module?
RNUserNotification;
```
  
