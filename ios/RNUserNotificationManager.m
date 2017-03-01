  //
//  RNUserNotificationManager.m
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/18/16.
//  Copyright © 2016 Clozr Inc. All rights reserved.
//

#import "RNUserNotificationManager.h"
#import <UserNotifications/UserNotifications.h>
#import "RNUserNotificationErrors.h"
#import "RNUserNotificationEvents.h"
#import "RCTUtils.h"
#import "RCTEventDispatcher.h"
#import "RCTBridge.h"
#import "RCTConvert+UserNotification.h"
#import "RNUserNotificationFormat.h"

NSDictionary* eventTable = nil;

@implementation RNUserNotificationManager
{
  RCTPromiseResolveBlock _requestPermissionsResolveBlock;
  RCTPromiseRejectBlock  _requestPermissionsRejectBlock;
  RNUserNotificationEvent* eventManager;
}

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

-(void)initEventTable
{
  if(!eventTable) {
    eventTable = @{
      RNUN_EV_RECEIVED_LOCAL_NOTIFICATION : [NSValue value:&@selector(handleLocalNotification:) withObjCType:@encode(SEL)],
      RNUN_EV_RECEIVED_REMOTE_NOTIFICATION : [NSValue value:&@selector(handleRemoteNotification:)  withObjCType:@encode(SEL)],
                  
      RNUN_EV_SUCCESS_REMOTE_NOTIFICATION_REG : [NSValue value:&@selector(handleRemoteNotificationsRegSuccess:) withObjCType:@encode(SEL)],
      RNUN_EV_FAILURE_REMOTE_NOTIFICATION_REG : [NSValue value:&@selector(handleRemoteNotificationsRegFailure:) withObjCType:@encode(SEL)],
      
      RNUN_EV_SUCCESS_USER_NOTIFICATION_SETTINGS : [NSValue value:&@selector(handleRegisterUserNotificationSettings:) withObjCType:@encode(SEL)],
                  
      RNUN_EV_RECEIVED_NOTIFICATION : [NSValue value:&@selector(handleUnifiedNotification:) withObjCType:@encode(SEL)],
      RNUN_EV_RECEIVED_NOTIFICATION_RESPONSE : [NSValue value:&@selector(handleUnifiedNotificationResponse:) withObjCType:@encode(SEL)],
    };
  }
  
}

-(void)startObserving
{
  [self initEventTable];
  for(NSString* event in eventTable) {
    NSLog(@"PUSH: registering event handler for %@", event);
    SEL aSel;
    [eventTable[event] getValue:&aSel];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:aSel
                                                 name:event
                                               object:nil];
  }
  eventManager = [RNUserNotificationEvent shared];
  [eventManager enableEvents];
}

-(void)stopObserving
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// SUPPORTED JAVASCRIPT EVENTS
// without this sendWithEventName won't work

- (NSArray<NSString *> *)supportedEvents
{
  return @[
    @"localNotificationReceived",
    @"remoteNotificationReceived",
    @"remoteNotificationsRegistered",
    @"remoteNotificationsRegistrationError",
    @"notificationReceived",
    @"notificationResponseReceived"
  ];
}


-(void)handleRemoteNotificationsRegSuccess:(NSNotification*)notification
{
  NSData* deviceToken = notification.userInfo[@"deviceToken"];
  
  NSLog(@"PUSH Device Token %@", deviceToken);
  
  NSMutableString *hexString = [NSMutableString string];
  NSUInteger deviceTokenLength = deviceToken.length;
  const unsigned char *bytes = deviceToken.bytes;
  for (NSUInteger i = 0; i < deviceTokenLength; i++) {
    [hexString appendFormat:@"%02x", bytes[i]];
  }
  
  [self sendEventWithName:@"remoteNotificationsRegistered" body:@{@"deviceToken" : [hexString copy]}];
}

-(void)handleRemoteNotificationsRegFailure:(NSNotification*)notification
{
  NSError* error = notification.userInfo[@"error"];
  NSLog(@"PUSH Reg Error: %@", error);
  [self sendEventWithName:@"remoteNotificationsRegistrationError" body:error.userInfo];
}


// NOTIFICATION HANDLING IOS 10

- (void)handleUnifiedNotification:(NSNotification *)notification
{
  UNNotification* unifiedNotification = notification.userInfo[@"notification"];
  [self sendEventWithName:@"notificationReceived" body:[unifiedNotification convertToDict]];
}

- (void)handleUnifiedNotificationResponse:(NSNotification *)notification
{
  UNNotificationResponse* response = notification.userInfo[@"response"];
  [self sendEventWithName:@"notificationResponseReceived" body:[response convertToDict]];
}

// NOTIFICATION HANDLING IOS 9

- (void)handleLocalNotification:(NSNotification *)notification
{
  UILocalNotification* localNotification = notification.userInfo[@"notification"];

  [self sendEventWithName:@"localNotificationReceived" body:[localNotification convertToDict]];
}

- (void)handleRemoteNotification:(NSNotification *)notification
{
  NSMutableDictionary* remoteNotification = [notification.userInfo[@"notification"] mutableCopy];
  remoteNotification[@"remote"] = @YES;
  [self sendEventWithName:@"remoteNotificationReceived" body:remoteNotification];
}


- (void)handleRegisterUserNotificationSettings:(NSNotification *)notification
{
  if (_requestPermissionsResolveBlock == nil) {
    return;
  }
  
  UIUserNotificationSettings *notificationSettings = notification.userInfo[@"notificationSettings"];
  NSDictionary *notificationTypes = @{
                                      @"alert": @((notificationSettings.types & UIUserNotificationTypeAlert) > 0),
                                      @"sound": @((notificationSettings.types & UIUserNotificationTypeSound) > 0),
                                      @"badge": @((notificationSettings.types & UIUserNotificationTypeBadge) > 0),
                                      @"api" : @"old",
                                      };
  
  _requestPermissionsResolveBlock(notificationTypes);
  _requestPermissionsResolveBlock = nil;
}



/// JAVASCRIPT INTERFACE ////


// BADGE MANAGEMENT

/**
 * Update the application icon badge number on the home screen
 */
RCT_EXPORT_METHOD(setApplicationIconBadgeNumber:(NSInteger)number)
{
  RCTSharedApplication().applicationIconBadgeNumber = number;
}

/**
 * Get the current application icon badge number on the home screen
 */
RCT_EXPORT_METHOD(getApplicationIconBadgeNumber:(RCTResponseSenderBlock)callback)
{
  callback(@[@(RCTSharedApplication().applicationIconBadgeNumber)]);
}


// AUTHORIZATION
RCT_EXPORT_METHOD(requestPermissions:(id)permissions
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  NSLog(@"PUSH: requestPermissions");
  if (RCTRunningInAppExtension()) {
    reject(RNUserNotificationPermissionRequestInvalid, nil, RCTErrorWithMessage(@"Requesting push notifications is currently unavailable in an app extension"));
    return;
  }
  
  if (_requestPermissionsResolveBlock != nil) {
    reject(RNUserNotificationPermissionRequestPending, nil, RCTErrorWithMessage(@"Cannot call requestPermissions twice before the first has returned."));
    return;
  }
  
  _requestPermissionsResolveBlock = resolve;
  _requestPermissionsRejectBlock  = reject;
  
  
  UIApplication *app = RCTSharedApplication();
  
  NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
  if (version.majorVersion == 10 && version.minorVersion == 0) {
    UNAuthorizationOptions types = [RCTConvert UNAuthorizationOptions:permissions];
    NSLog(@"PUSH: requestPermissions options %@", @(types));

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:types completionHandler:^(BOOL granted, NSError * _Nullable error){
      if( !error ){
        [app registerForRemoteNotifications];
        NSDictionary *resp = @{@"granted": @(granted), @"api": @"new"};
        NSLog(@"PUSH: grant %d", granted);
        resolve(resp);
        _requestPermissionsResolveBlock = nil;
      } else {
        reject(RNUserNotificationPermissionRequestDenied, nil, error);
      }
    }];
  } else {
    UIUserNotificationType types = [RCTConvert UIUserNotificationType:permissions];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:(NSUInteger)types categories:nil];
    [app registerUserNotificationSettings:notificationSettings];
  }
}

RCT_EXPORT_METHOD(getNotificationSettings:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject)
{
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    
    NSDictionary* resp = [settings convertToDict];
    resolve(resp);
  }];
}

RCT_EXPORT_METHOD(abandonPermissions)
{
  [RCTSharedApplication() unregisterForRemoteNotifications];
}

RCT_EXPORT_METHOD(triggerWaitingNotifications)
{
  [eventManager triggerWaitingNotifications];
}

// IOS 10 - Custom Actions & Notification

RCT_EXPORT_METHOD(setNotificationCategories:(id)json
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(__unused RCTPromiseRejectBlock)reject)
{
  NSArray<UNNotificationCategory*> *categoriesArray = [RCTConvert UNNotificationCategoryArray:json];
  NSSet<UNNotificationCategory*> *categories = [NSSet setWithArray:categoriesArray];
  
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center setNotificationCategories:categories];
  NSDictionary *resp = @{@"success": @(TRUE)};
  NSLog(@"PUSH Categories Saved %@", resp);
  resolve(resp);
}


RCT_EXPORT_METHOD(getNotificationCategories:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject)
{
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
    NSMutableArray<NSDictionary *> *categoryList = [NSMutableArray new];
    for(UNNotificationCategory* category in categories) {
      [categoryList addObject:[category convertToDict]];
    }
    resolve(categoryList);
  }];
}

- (void)handleNotificationResponse:(UNNotificationResponse*)notificationResponse
{
  NSDictionary *notification  = [notificationResponse convertToDict];
  [self sendEventWithName:@"notificationResponseReceived" body:notification];
}


// IOS 9 Schedule Notification


RCT_EXPORT_METHOD(cancelAllLocalNotifications)
{
  [RCTSharedApplication() cancelAllLocalNotifications];
}

RCT_EXPORT_METHOD(cancelLocalNotifications:(NSDictionary<NSString *, id> *)userInfo)
{
  for (UILocalNotification *notification in [UIApplication sharedApplication].scheduledLocalNotifications) {
    __block BOOL matchesAll = YES;
    NSDictionary<NSString *, id> *notificationInfo = notification.userInfo;
    // Note: we do this with a loop instead of just `isEqualToDictionary:`
    // because we only require that all specified userInfo values match the
    // notificationInfo values - notificationInfo may contain additional values
    // which we don't care about.
    [userInfo enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
      if (![notificationInfo[key] isEqual:obj]) {
        matchesAll = NO;
        *stop = YES;
      }
    }];
    if (matchesAll) {
      [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
  }
}

// IOS 10 Managing Notification Requests

RCT_EXPORT_METHOD(addNotification:(UNNotificationRequest *)notification
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center addNotificationRequest:notification withCompletionHandler:^(NSError * _Nullable error) {
    NSLog(@"PUSH Notification scheduled %@", error);
    if( !error ){
      NSDictionary *resp = @{@"success": @(TRUE)};
      NSLog(@"PUSH Notification succeeded %@", resp);
      resolve(resp);
    } else {
      reject(RNUserNotificationPermissionRequestDenied, nil, error);
    }
  }];
}

// IOS 9 Add Notification
RCT_EXPORT_METHOD(scheduleLocalNotification:(UILocalNotification *)notification)
{
  NSDate *fireDate = notification.fireDate;
  NSDictionary<NSString *, id>* userInfo = notification.userInfo;
  NSLog(@"fireDate: %@", fireDate);
  for (NSString *key in userInfo) {
    id object = [userInfo objectForKey:key];
    NSLog(@"USERINFO: %@ for key: %@", object, key);
  }
  
  [RCTSharedApplication() scheduleLocalNotification:notification];
}


RCT_EXPORT_METHOD(removePendingNotifications:(id)json)
{
  NSArray<NSString*>*  ids = [RCTConvert NSStringArray:json];
  NSLog(@"PUSH remove notifications: %@", ids);
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  if(ids) {
    [center removePendingNotificationRequestsWithIdentifiers:ids];
  } else {
    [center removeAllPendingNotificationRequests];
  }
}

RCT_EXPORT_METHOD(removeDeliveredNotifications:(id)json)
{
  NSArray<NSString*>*  ids = [RCTConvert NSStringArray:json];
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  if(ids) {
    [center removeDeliveredNotificationsWithIdentifiers:ids];
  } else {
    [center removeAllDeliveredNotifications];
  }
}

RCT_EXPORT_METHOD(getPendingNotifications:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject)
{
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
    NSMutableArray<NSDictionary *> *notificationList = [NSMutableArray new];
    for (UNNotificationRequest *request in requests) {
      [notificationList addObject:[request convertToDict]];
    }
    resolve(notificationList);
  }];
}

RCT_EXPORT_METHOD(getDeliveredNotifications:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject)
{
  UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
  [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
    NSMutableArray<NSDictionary *> *notificationList = [NSMutableArray new];
    for (UNNotification *notification in notifications) {
      [notificationList addObject:[notification convertToDict]];
    }
    resolve(notificationList);
  }];
}

RCT_EXPORT_METHOD(getInitialNotificationResponse:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject)
{
  if(!eventManager) {
    eventManager = [RNUserNotificationEvent shared];
  }
  UNNotificationResponse* response = [eventManager getInitialNotificationResponse];
  if(response) {
    resolve([response convertToDict]);
  } else {
    resolve(nil);
  }
}

@end
