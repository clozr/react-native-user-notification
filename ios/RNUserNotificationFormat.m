//
//  RNUserNotificationFormat.m
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/19/16.
//  Copyright © 2016 Clozr Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <React/RCTUtils.h>
#import "RNUserNotificationFormat.h"

@implementation NSDateComponents(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"year"] = @(self.day);
  data[@"month"] = @(self.month);
  data[@"day"] = @(self.day);
  data[@"hour"] = @(self.hour);
  data[@"minute"] = @(self.minute);
  data[@"second"] = @(self.second);
  return data;
}
@end

@implementation UILocalNotification(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  if (self.fireDate) {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
    NSString *fireDateString = [formatter stringFromDate:self.fireDate];
    data[@"fireDate"] = fireDateString;
  }
  data[@"alertAction"] = RCTNullIfNil(self.alertAction);
  data[@"alertBody"] = RCTNullIfNil(self.alertBody);
  data[@"applicationIconBadgeNumber"] = @(self.applicationIconBadgeNumber);
  data[@"category"] = RCTNullIfNil(self.category);
  data[@"soundName"] = RCTNullIfNil(self.soundName);
  data[@"userInfo"] = RCTNullIfNil(RCTJSONClean(self.userInfo));
  data[@"remote"] = @NO;
  return data;
}
@end

@implementation UNNotificationTrigger(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"type"] = @"invalid";
  return data;
}
@end

@implementation UNPushNotificationTrigger(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"type"] = @"push";
  return data;
}
@end

@implementation UNTimeIntervalNotificationTrigger(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"type"] = @"timeInterval";
  data[@"repeats"] = @(self.repeats);
  data[@"timeInterval"] = @((double)self.timeInterval);
  return data;
}
@end

@implementation UNCalendarNotificationTrigger(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"type"] = @"calendar";
  data[@"repeats"] = @(self.repeats);
  data[@"dateComponents"] = [self.dateComponents convertToDict];
  //data[@"date"] = [NSCalendar dateFromComp];
  return data;
}
@end

@implementation CLCircularRegion(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"identifier"] = self.identifier;
  data[@"center"] = @{@"latitude": @(self.center.latitude), @"longitude": @(self.center.longitude)};
  data[@"radius"] = @(self.radius);
  data[@"notifyOnEnter"] = @(self.notifyOnEntry);
  data[@"notifyOnExit"] = @(self.notifyOnExit);
  return data;
}
@end

@implementation UNLocationNotificationTrigger(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"type"] = @"location";
  data[@"repeats"] = @(self.repeats);
  CLCircularRegion* region = (CLCircularRegion*)self.region;
  data[@"region"] = [region convertToDict];
  return data;
}
@end

RNRCT_FORMAT(UNNotificationContent, {
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"badge"] = RCTNullIfNil(self.badge);
  
  data[@"title"] = RCTNullIfNil(self.title);
  data[@"subtitle"] = RCTNullIfNil(self.subtitle);
  data[@"body"] = RCTNullIfNil(self.body);

  data[@"threadIdentifier"] = RCTNullIfNil(self.threadIdentifier);
  data[@"categoryIdentifier"] = RCTNullIfNil(self.categoryIdentifier);
  data[@"launchImageName"] = RCTNullIfNil(self.threadIdentifier);
  data[@"threadIdentifier"] = RCTNullIfNil(self.threadIdentifier);
  data[@"userInfo"] = RCTNullIfNil(RCTJSONClean(self.userInfo));

  return data;
})


@implementation UNNotificationRequest(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"identifier"] = self.identifier;
  data[@"content"] = [self.content convertToDict];
  data[@"trigger"] = [self.trigger convertToDict];
  return data;
}
@end


@implementation UNNotification(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  
  NSDateFormatter *formatter = [NSDateFormatter new];
  [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
  NSString *fireDateString = [formatter stringFromDate:self.date];
  data[@"date"] = fireDateString;
  data[@"request"] = [self.request convertToDict];
  return data;
}
@end

@implementation UNNotificationResponse(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  
  data[@"notification"] = [self.notification convertToDict];
  data[@"actionId"] = self.actionIdentifier;
  
  return data;
}
@end

@implementation UNTextInputNotificationResponse(RNRCTFormat)
-(NSDictionary*)convertToDict
{
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  
  data[@"notification"] = [self.notification convertToDict];
  data[@"actionId"] = self.actionIdentifier;
  data[@"userText"] = self.userText;
  return data;
}
@end

RNRCT_FORMAT(UNNotificationSettings, {
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"authorizationStatus"] = @(self.authorizationStatus);
  data[@"sound"] = @(self.soundSetting);
  data[@"alert"] = @(self.alertSetting);
  data[@"badge"] = @(self.badgeSetting);
  data[@"notificationCenter"] = @(self.notificationCenterSetting);
  data[@"lockScreen"] = @(self.lockScreenSetting);
  data[@"alertStyle"] = @(self.alertStyle);
  return data;
})

RNRCT_FORMAT(UNTextInputNotificationAction, {
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  
  data[@"identifier"] = self.identifier;
  data[@"title"] = self.title;
  data[@"textInputButtonTitle"] = self.textInputButtonTitle;
  data[@"textInputPlaceholder"] = self.textInputPlaceholder;
  data[@"options"] = @(self.options);
  return data;
})

RNRCT_FORMAT(UNNotificationAction, {
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  
  data[@"identifier"] = self.identifier;
  data[@"title"] = self.title;
  data[@"options"] = @(self.options);
  return data;
})

RNRCT_FORMAT(UNNotificationCategory, {
  NSMutableDictionary *data = [NSMutableDictionary dictionary];
  data[@"identifier"] = self.identifier;
  NSMutableArray<NSDictionary *> *actions = [NSMutableArray new];
  for(UNNotificationAction* action in self.actions) {
    [actions addObject:[action convertToDict] ];
  }
  data[@"actions"] = actions;
  data[@"intentIdentifiers"] = self.intentIdentifiers;
  data[@"options"] = @(self.options);
  return data;
})

