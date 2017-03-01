
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

`$ npm install react-native-user-notification --save`

### Mostly automatic installation

`$ react-native link react-native-user-notification`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-user-notification` and add `RNUserNotification.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNUserNotification.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<


## Usage
```javascript
import RNUserNotification from 'react-native-user-notification';

// TODO: What to do with the module?
RNUserNotification;
```
  
