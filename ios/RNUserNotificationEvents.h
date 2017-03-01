//
//  RNUserNotificationEvents.h
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/19/16.
//  Copyright © 2016 Clozr Inc. All rights reserved.
//  Website: www.clozr.com
//  License: See License File

#ifndef RNUserNotificationEvents_h
#define RNUserNotificationEvents_h

#import <UserNotifications/UserNotifications.h>

// IOS 10
static NSString *const RNUN_EV_RECEIVED_NOTIFICATION = @"NotificationReceived";
static NSString *const RNUN_EV_RECEIVED_NOTIFICATION_RESPONSE = @"NotificationResponseReceived";

// IOS 9
static NSString *const RNUN_EV_RECEIVED_LOCAL_NOTIFICATION  = @"LocalNotificationReceived";
static NSString *const RNUN_EV_RECEIVED_REMOTE_NOTIFICATION = @"RemoteNotificationReceived";

static NSString *const RNUN_EV_SUCCESS_REMOTE_NOTIFICATION_REG = @"RemoteNotificationsRegistered";
static NSString *const RNUN_EV_FAILURE_REMOTE_NOTIFICATION_REG = @"RemoteNotificationsRegistrationError";
static NSString *const RNUN_EV_SUCCESS_USER_NOTIFICATION_SETTINGS = @"RegisterUserNotificationSettings";


@interface RNUserNotificationEvent: NSObject
+ (id)shared;
- (void)postEvent:(NSNotificationName)eventName userInfo:(NSDictionary*)userInfo;
- (void)enableEvents;
- (void)triggerWaitingNotifications;
- (UNNotificationResponse*)getInitialNotificationResponse;
@end

#endif /* RNUserNotificationEvents_h */
