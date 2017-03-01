//
//  RNUserNotificationFormat.h
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/19/16.
//  Copyright © 2016 Clozr Inc. All rights reserved.
//

#ifndef RNUserNotificationFormat_h
#define RNUserNotificationFormat_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CLCircularRegion.h>
#import <UserNotifications/UserNotifications.h>

#define DECLARE_RNRCT_FORMAT(type) \
@interface type(RNRCTFormat) \
-(NSDictionary*)convertToDict; \
@end

#define RNRCT_FORMAT(type, code) \
@implementation type(RNRCTFormat) \
-(NSDictionary*)convertToDict \
code \
@end

@interface RCTFormat: NSObject
+(NSDictionary*)UILocalNotification:(UILocalNotification*)notification;
+(NSDictionary*)UNNotification:(UNNotification*)notification;
+(NSDictionary*)UNNotificationRequest:(UNNotificationRequest*)request;
+(NSDictionary*)UNNotificationResponse:(UNNotificationResponse*)response;
@end


DECLARE_RNRCT_FORMAT(UILocalNotification)

DECLARE_RNRCT_FORMAT(UNNotificationContent)

DECLARE_RNRCT_FORMAT(UNNotificationTrigger)

DECLARE_RNRCT_FORMAT(CLRegion)

DECLARE_RNRCT_FORMAT(UNNotificationRequest)

DECLARE_RNRCT_FORMAT(UNNotificationResponse)

DECLARE_RNRCT_FORMAT(UNNotification)

DECLARE_RNRCT_FORMAT(UNNotificationSettings)

DECLARE_RNRCT_FORMAT(UNNotificationCategory)


#endif /* RNUserNotificationFormat_h */
