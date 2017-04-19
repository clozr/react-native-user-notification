//
//  RCTConvert+UserNotification.h
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/19/16.
//  Copyright © 2016 Clozr Inc. All rights reserved.
//  License: See License File

#ifndef RCTConvert_UserNotification_h
#define RCTConvert_UserNotification_h

#import <React/RCTConvert.h>

#define DECLARE_RCT_CONVERTER(type) \
+ (type*)type:(id)json

#define DECLARE_RCT_CUSTOM_CONVERTER(type, name) \
+ (type)name:(id)json


@interface RCTConvert(NSDateComponents)
DECLARE_RCT_CONVERTER(NSDateComponents);
@end

@interface RCTConvert(UNNotificationContent)
DECLARE_RCT_CONVERTER(UNNotificationContent);
@end

@interface RCTConvert(UNNotificationTrigger)
DECLARE_RCT_CONVERTER(UNNotificationTrigger);
@end

@interface RCTConvert(UNNotificationRequest)
DECLARE_RCT_CONVERTER(UNNotificationRequest);
@end

@interface RCTConvert(UIUserNotificationType)
DECLARE_RCT_CUSTOM_CONVERTER(UIUserNotificationType, UIUserNotificationType);
@end

@interface RCTConvert(UNAuthorizationOptions)
DECLARE_RCT_CUSTOM_CONVERTER(UNAuthorizationOptions, UNAuthorizationOptions);
@end

@interface RCTConvert(UNNotificationCategory)

DECLARE_RCT_CONVERTER(UNNotificationCategory);
DECLARE_RCT_CUSTOM_CONVERTER(NSArray<UNNotificationCategory*>*, UNNotificationCategoryArray);

@end

#endif /* RCTConvert_UserNotification_h */
