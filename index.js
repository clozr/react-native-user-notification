/**
 * Copyright (c) 2016-present, Clozr Inc.
 * All rights reserved.
 *
 * @providesModule UserNotification
 * @flow
 */
'use strict';

const NativeEventEmitter = require('NativeEventEmitter');
const RNUserNotification = require('NativeModules').RNUserNotification;
const invariant = require('fbjs/lib/invariant');
const _ = require('underscore');

const UNXEventEmitter = new NativeEventEmitter(RNUserNotification);


const _notifHandlers = new Map();

const JS_TO_NATIVE_EVENTS = {
  notification: {
    nativeEvent: 'notificationReceived',
    transform: nx => nx
  },
  notificationResponse: {
    nativeEvent: 'notificationResponseReceived',
    transform: nxr => nxr
  },
  localNotification: {
    nativeEvent: 'localNotificationReceived',
    transform: lx => lx
  },
  register: {
    nativeEvent: 'remoteNotificationsRegistered',
    transform: r => r.deviceToken
  },
  registerError: {
    nativeEvent: 'remoteNotificationsRegistrationError',
    transform: e => e
  }
};

class NotificationRequest {
  constructor(id:string, title:string, subtitle:string, body:string, badge:number=1) {
    this.id = id;
    this.content = { title, subtitle, body, badge};
    this.trigger = null;
  }

  set threadIdentifier(tid:string) {
    if(tid) {
      this.content.threadIdentifier = tid;
    }
  }

  set categoryIdentifier(cid:string) {
    if(cid) {
      this.content.categoryIdentifier = cid;
    }
  }

  set launchImageName(image:string) {
    if(image) {
      this.content.launchImageName = image;
    }
  }

  set soundName(sound:string) {
    if(sound) {
      this.content.soundName = sound;
    }
  }

  set userInfo(data:string) {
    if(data) {
      this.content.userInfo = data;
    }
  }
 
  setIntervalTrigger(timeInterval:number, repeats:boolean=false) {
    this.trigger = { type: 'timeInterval', repeats, timeInterval };
  }

  setCalendarTrigger(date:Date, repeats:boolean=false) {
    this.trigger = { type: 'calendar', repeats, date };
  }

  setScheduleTrigger(schedule:Object, repeats:boolean=false) {
    this.trigger = { type: 'calendar', repeats, schedule };
  }

  setLocationTrigger(longitude:double, latitude:double, radius:dobule, repeats:boolean=false, notifyOnEnter:boolean=true, notifyOnExit:boolean=false) {
    let center = { longitude, latitude };
    this.trigger = { type: 'location', repeats, center, radius, notifyOnEnter, notifyOnExit};
  }

  /**
   * Schedules the localNotification for future presentation.
   *
   * details is an object containing:
   *
   * - `fireDate` : The date and time when the system should deliver the notification.
   * - `alertBody` : The message displayed in the notification alert.
   * - `alertAction` : The "action" displayed beneath an actionable notification. Defaults to "view";
   * - `soundName` : The sound played when the notification is fired (optional).
   * - `category`  : The category of this notification, required for actionable notifications (optional).
   * - `userInfo` : An optional object containing additional notification data.
   * - `applicationIconBadgeNumber` (optional) : The number to display as the app's icon badge. Setting the number to 0 removes the icon badge.
   */

  schedule(): Promise {
    let req = {id: this.id, trigger: this.trigger, content: this.content};
    __DEV__ && console.log('[PUSH] scheduling:', req);
    return RNUserNotification.addNotification(req);
  }
}


/**
 * Handle push notifications for your app, including permission handling and
 * icon badge number.
 *
 * To get up and running, [configure your notifications with Apple](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/AddingCapabilities/AddingCapabilities.html#//apple_ref/doc/uid/TP40012582-CH26-SW6)
 * and your server-side system. To get an idea, [this is the Parse guide](https://parse.com/tutorials/ios-push-notifications).
 *
 * [Manually link](docs/linking-libraries-ios.html#manual-linking) the UserNotification library
 *
 * - Add the following to your Project: `node_modules/react-native/Libraries/UserNotification/RCTPushNotification.xcodeproj`
 * - Add the following to `Link Binary With Libraries`: `libRCTPushNotification.a`
 * - Add the following to your `Header Search Paths`:
 * `$(SRCROOT)/../node_modules/react-native/Libraries/UserNotification` and set the search to `recursive`
 *
 * Finally, to enable support for `notification` and `register` events you need to augment your AppDelegate.
 *
 * At the top of your `AppDelegate.m`:
 *
 *   `#import "RNUserNotification.h"`
 *
 * And then in your AppDelegate implementation add the following:
 *
 *   ```
 *    // Required to register for notifications
 *    - (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
 *    {
 *     [RNUserNotification didRegisterUserNotificationSettings:notificationSettings];
 *    }
 *    // Required for the register event.
 *    - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
 *    {
 *     [RNUserNotification didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
 *    }
 *    // Required for the notification event.
 *    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
 *    {
 *     [RNUserNotification didReceiveRemoteNotification:notification];
 *    }
 *    // Required for the localNotification event.
 *    - (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
 *    {
 *     [RNUserNotification didReceiveLocalNotification:notification];
 *    }
 *    - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
 *    {
 *      NSLog(@"%@", error);
 *    }
 *   ```
 */

const ACTIONS_OPTIONS = ['authRequired' , 'destructive', 'foreground'];

var checkOptions = function(options, validOptions) {
  let invalidOpts = _.difference(options||[], validOptions);
  invariant(invalidOpts.length==0, 'invalid options: ', invalidOpts);
};


class NotificationCategory {
  constructor(id:string) {
    this.categoryIdentifier = id;
    this.actions = [];
  }

  addAction(identifier:string, title:string, options:Array<string>) {
    checkOptions(options, ACTIONS_OPTIONS);
    this.actions.push({identifier, title, options});
  }

  addTextInputAction(identifier:string, title:string, textInputButtonTitle:string, textInputPlaceholder:string, options:Array<string>) {
    checkOptions(options, ACTIONS_OPTIONS);
    this.actions.push({identifier, title, options, textInputButtonTitle, textInputPlaceholder});
  }

  json() {
    return {categoryIdentifier: this.categoryIdentifier, actions: this.actions};
  }

  static create(id:string) {
    return new NotificationCategory(id)
  }

  static categories = [];

  static add(category) {
    this.categories.push(category);

    let catoriesList = this.categories.map(c => c.json());
    __DEV__ && console.log('PUSH: ADDING CATEGORIES', catoriesList);
    RNUserNotification.setNotificationCategories(catoriesList);
  }

  static get() {
    return RNUserNotification.getNotificationCategories();
  }
}

class UserNotification {

  static createRequest(...args) {
    return new NotificationRequest(...args);
  }

  static Category = NotificationCategory;


  /**
   * get initial notifications
   */
  static initialResponse = null;
  static getInitialNotificationResponse(): Promise {
    if(!this.initialResponse) {
      this.initialResponse = RNUserNotification.getInitialNotificationResponse();
      this.initialResponse.then((resp) => {
        __DEV__ && console.log("PUSH INITIAL RESPONSE", resp);
      });
    }
    return this.initialResponse;
  }

  /**
   * get pending notifications
   */
  static getPendingNotifications(): Promise {
    return RNUserNotification.getPendingNotifications();
  }

  /**
   * Removes pending notifications
   */
  static removePendingNotifications(notificationIds:Array<string> = null) {
    return RNUserNotification.removePendingNotifications(notificationIds);
  }

  /**
   * get delivered notifications
   */
  static getDeliveredNotifications(): Promise {
    return RNUserNotification.getDeliveredNotifications();
  }

  /**
   * Removes delivered notifications
   */
  static removeDeliveredNotifications(notificationIds:Array<string> = null) {
    return RNUserNotification.removeDeliveredNotifications(notificationIds);
  }


  /**
   * Sets the badge number for the app icon on the home screen
   */
  static setApplicationIconBadgeNumber(number: number) {
    RNUserNotification.setApplicationIconBadgeNumber(number);
  }

  /**
   * Gets the current badge number for the app icon on the home screen
   */
  static getApplicationIconBadgeNumber(callback: Function) {
    RNUserNotification.getApplicationIconBadgeNumber(callback);
  }

  /**
   * Attaches a listener to remote or local notification events while the app is running
   * in the foreground or the background.
   *
   * Valid events are:
   *
   * - `notification` : Fired when a remote notification is received. The
   *   handler will be invoked with an instance of `UserNotification`.
   * - `localNotification` : Fired when a local notification is received. The
   *   handler will be invoked with an instance of `UserNotification`.
   * - `register`: Fired when the user registers for remote notifications. The
   *   handler will be invoked with a hex string representing the deviceToken.
   */
  static addEventListener(type: string, handler: Function) {
    let eventEntry = JS_TO_NATIVE_EVENTS[type];
    invariant(
      eventEntry, 'invalid notification event: ' + type
    );
    let {nativeEvent, transform} = eventEntry;
    let listener = UNXEventEmitter.addListener(nativeEvent, nx => handler(transform(nx)));
    _notifHandlers.set(handler, listener);
  }

  /**
   * Removes the event listener. Do this in `componentWillUnmount` to prevent
   * memory leaks
   */
  static removeEventListener(type: string, handler: Function) {
    let eventEntry = JS_TO_NATIVE_EVENTS[type];
    invariant(
      eventEntry, 'invalid notification event: ' + type
    );
    var listener = _notifHandlers.get(handler);
    if (!listener) {
      return;
    }
    listener.remove();
    _notifHandlers.delete(handler);
  }

  /**
   * Requests notification permissions from iOS, prompting the user's
   * dialog box. By default, it will request all notification permissions, but
   * a subset of these can be requested by passing a map of requested
   * permissions.
   * The following permissions are supported:
   *
   *   - `alert`
   *   - `badge`
   *   - `sound`
   *
   * If a map is provided to the method, only the permissions with truthy values
   * will be requested.

   * This method returns a promise that will resolve when the user accepts,
   * rejects, or if the permissions were previously rejected. The promise
   * resolves to the current state of the permission.
   */
  static requestPermissions(permissions?: {
    alert?: boolean,
    badge?: boolean,
    sound?: boolean
  }){
    let requestedPermissions;
    if (permissions) {
      requestedPermissions = {
        alert: !!permissions.alert,
        badge: !!permissions.badge,
        sound: !!permissions.sound
      };
    }
    return RNUserNotification.requestPermissions(requestedPermissions || null);
  }

  /**
   * Unregister for all remote notifications received via Apple Push Notification service.
   *
   * You should call this method in rare circumstances only, such as when a new version of
   * the app removes support for all types of remote notifications. Users can temporarily
   * prevent apps from receiving remote notifications through the Notifications section of
   * the Settings app. Apps unregistered through this method can always re-register.
   */
  static abandonPermissions() {
    RNUserNotification.abandonPermissions();
  }

  static getNotificationSettings(): Promise {
    return RNUserNotification.getNotificationSettings();
  }

  static triggerWaitingNotifications() {
    RNUserNotification.triggerWaitingNotifications();
  }
}

module.exports = UserNotification;
