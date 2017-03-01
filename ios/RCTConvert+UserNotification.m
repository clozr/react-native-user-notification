//
//  RCTConvert+UserNotification.m
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/18/16.
//  Copyright © 2016 Clozr Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CLCircularRegion.h>


#import "RCTConvert+UserNotification.h"


@implementation RCTConvert(UNNotificationContent)
+ (UNNotificationContent*)UNNotificationContent:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];

  UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
  
  content.title = [RCTConvert NSString:details[@"title"]];
  NSLog(@"PUSH set title=%@", content.title);
  content.subtitle = [RCTConvert NSString:details[@"subtitle"]];
  NSLog(@"PUSH set subtitle=%@", content.subtitle);

  content.body = [RCTConvert NSString:details[@"body"]];
  NSLog(@"PUSH set body=%@", content.body);

  content.badge = [RCTConvert NSNumber:details[@"badge"]];
  NSLog(@"PUSH set badge=%@", content.badge);


  content.threadIdentifier = [RCTConvert NSString:details[@"threadIdentifier"]];
  NSLog(@"PUSH set thread=%@", content.threadIdentifier);

  content.categoryIdentifier = [RCTConvert NSString:details[@"categoryIdentifier"]];
  NSLog(@"PUSH set category=%@", content.categoryIdentifier);

  content.launchImageName = [RCTConvert NSString:details[@"launchImageName"]];
  NSLog(@"PUSH set launchImage=%@", content.launchImageName);

  NSString* soundName = [RCTConvert NSString:details[@"soundName"]];
  content.sound = soundName ? [UNNotificationSound soundNamed:soundName] : [UNNotificationSound defaultSound ];
  NSLog(@"PUSH set sound=%@", content.sound);
  
  content.userInfo = [RCTConvert NSDictionary:details[@"userInfo"]];


  
  return content;
}
@end

@implementation RCTConvert(NSDateComponents)
+ (NSDateComponents*) NSDateComponents:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];

  NSDictionary* comp = @{@"year": @(NSCalendarUnitYear),
                                 @"month" :  @(NSCalendarUnitMonth),
                                 @"day" :    @(NSCalendarUnitDay),
                                 @"month" :  @(NSCalendarUnitHour),
                                 @"month" :  @(NSCalendarUnitMinute),
                                 @"seconds": @(NSCalendarUnitSecond)
                                 };
  NSDateComponents* date = [[NSDateComponents alloc] init];
  for (NSString *key in details) {
    NSInteger value = [RCTConvert NSInteger:[details objectForKey:key]];
    [date setValue:value forComponent:[[comp objectForKey:key] integerValue]];
  }
  
  return date;
}
@end

@implementation RCTConvert(CLLocationCoordinate2D)
+ (CLLocationCoordinate2D)CLLocationCoordinate2D:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  CLLocationCoordinate2D center;
  center.latitude = [RCTConvert double:details[@"latitude"]];
  center.longitude = [RCTConvert double:details[@"longitude"]];
  return center;
}
@end

@implementation RCTConvert(CLCircularRegion)
+ (CLCircularRegion*)CLCircularRegion:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  NSString* identifier = [RCTConvert NSString:details[@"id"]];

  CLLocationCoordinate2D center = [RCTConvert CLLocationCoordinate2D:details[@"center"]];
  CLLocationDistance radius = [RCTConvert double:details[@"radius"]];
  
  CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:center radius:radius identifier:identifier];

  region.notifyOnEntry = [RCTConvert BOOL:details[@"notifyOnEntry"]];
  region.notifyOnExit = [RCTConvert BOOL:details[@"notifyOnExit"]];
  
  return region;
}
@end

@implementation RCTConvert(UNLocationNotificationTrigger)
+ (UNLocationNotificationTrigger*)UNLocationNotificationTrigger:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  CLRegion* region =  [RCTConvert CLCircularRegion:details[@"region"]];
  return [UNLocationNotificationTrigger
          triggerWithRegion:region
          repeats:[RCTConvert BOOL:details[@"repeats"]]];
}
@end

@implementation RCTConvert(UNTimeIntervalNotificationTrigger)
+ (UNTimeIntervalNotificationTrigger*)UNTimeIntervalNotificationTrigger:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  NSTimeInterval interval = [RCTConvert NSTimeInterval:details[@"timeInterval"]];
  return [UNTimeIntervalNotificationTrigger
            triggerWithTimeInterval: interval
            repeats: [RCTConvert BOOL:details[@"repeats"]]];
}
@end

@implementation RCTConvert(UNCalendarNotificationTrigger)
+ (UNCalendarNotificationTrigger*)UNCalendarNotificationTrigger:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  NSDateComponents* dateComp = nil;
  
  NSDate* date = [RCTConvert NSDate:details[@"date"]];
  NSLog(@"PUSH calendar trigger date: %@", date);

  if(date) {
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit units = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    dateComp = [cal components:units fromDate:date];
    NSLog(@"PUSH calendar trigger dateAAA: %@", date);

  } else {
    dateComp = [RCTConvert NSDateComponents:details[@"schedule"]];
  }
  
  if(!dateComp) {
    RCTLogError(@"invalid date component specified");
  }
  NSLog(@"PUSH calendar trigger dateComp: y=%ld m=%ld  d=%ld h=%ld mm=%ld ss=%ld", dateComp.year, dateComp.month, dateComp.day, dateComp.hour, dateComp.minute, dateComp.second);

  
  return [UNCalendarNotificationTrigger
          triggerWithDateMatchingComponents:dateComp
          repeats:[RCTConvert BOOL:details[@"repeats"]]];
}
@end

@implementation RCTConvert(UNNotificationTrigger)
+ (UNNotificationTrigger*) UNNotificationTrigger:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  NSString* triggerType = [RCTConvert NSString:details[@"type"]];
  
  if([triggerType isEqual: @"timeInterval"]) {
    return [RCTConvert UNTimeIntervalNotificationTrigger:json];
  } else if([triggerType isEqual: @"calendar"]) {
    return [RCTConvert UNCalendarNotificationTrigger:json];
  } else {
    RCTLogError(@"%@ trigger is not supported", triggerType);
  }
  return nil;
}
@end

@implementation RCTConvert (UNNotificationRequest)

+ (UNNotificationRequest*)UNNotificationRequest:(id)json
{
  NSDictionary<NSString *, id> *details = [self NSDictionary:json];
  NSString* reqId = [RCTConvert NSString:details[@"id"]];
  UNNotificationContent* content = [RCTConvert UNNotificationContent:details[@"content"]];
  UNNotificationTrigger* trigger = [RCTConvert UNNotificationTrigger:details[@"trigger"]];
  UNNotificationRequest *notification = [UNNotificationRequest requestWithIdentifier:reqId content:content trigger:trigger];
  
  return notification;
}

@end

@implementation RCTConvert(UIUserNotificationType)

+(UIUserNotificationType)UIUserNotificationType:(id)json
{
  UIUserNotificationType types = UIUserNotificationTypeNone;
  NSDictionary<NSString *, id> *permissions = [self NSDictionary:json];
  if (permissions) {
    if ([RCTConvert BOOL:permissions[@"alert"]]) {
      types |= UIUserNotificationTypeAlert;
    }
    if ([RCTConvert BOOL:permissions[@"badge"]]) {
      types |= UIUserNotificationTypeBadge;
    }
    if ([RCTConvert BOOL:permissions[@"sound"]]) {
      types |= UIUserNotificationTypeSound;
    }
  } else {
    types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
  }
  return types;
}

@end


@implementation RCTConvert(UNAuthorizationOptions)

+(UNAuthorizationOptions)UNAuthorizationOptions:(id)json
{
  UNAuthorizationOptions types = UNAuthorizationOptionNone;
  NSDictionary<NSString *, id> *permissions = [self NSDictionary:json];
  
  if (permissions) {
    if ([RCTConvert BOOL:permissions[@"alert"]]) {
      types |= UNAuthorizationOptionAlert;
    }
    if ([RCTConvert BOOL:permissions[@"badge"]]) {
      types |= UNAuthorizationOptionBadge;
    }
    if ([RCTConvert BOOL:permissions[@"sound"]]) {
      types |= UNAuthorizationOptionSound;
    }
    /*
    if ([RCTConvert BOOL:permissions[@"carplay"]]) {
      types |= UNAuthorizationOptionCarPlay;
    }*/
  } else {
    types = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
  }
  return types;
}

@end

@implementation RCTConvert(UNNotificationActionOptions)
RCT_MULTI_ENUM_CONVERTER(UNNotificationActionOptions, (@{
  @"authRequired": @(UNNotificationActionOptionAuthenticationRequired),
  @"destructive" : @(UNNotificationActionOptionDestructive),
  @"foreground"  : @(UNNotificationActionOptionForeground),
}),UNNotificationActionOptionNone, integerValue);
@end


@implementation RCTConvert(UNNotificationAction)
+(UNNotificationAction*)UNNotificationAction:(id)json
{

  NSDictionary<NSString *, id> *data = [self NSDictionary:json];
  NSString* identifier = [RCTConvert NSString:data[@"identifier"]];
  NSString* title = [RCTConvert NSString:data[@"title"]];
  UNNotificationActionOptions options = [RCTConvert UNNotificationActionOptions:data[@"options"]];
  
  NSString* textButtonTitle = [RCTConvert NSString:data[@"textInputButtonTitle"]];
  if(textButtonTitle) {
    NSString* placeholder = [RCTConvert NSString:data[@"textInputPlaceholder"]];
    return [UNTextInputNotificationAction actionWithIdentifier:identifier title:title options:options textInputButtonTitle:textButtonTitle textInputPlaceholder:placeholder ];
  } else {
    return [ UNNotificationAction actionWithIdentifier:identifier title:title options:options ];
  }
}

RCT_ARRAY_CONVERTER(UNNotificationAction);

@end


@implementation RCTConvert(UNNotificationCategory)

RCT_MULTI_ENUM_CONVERTER(UNNotificationCategoryOptions, (@{
  @"none": @(UNNotificationCategoryOptionNone),
  @"customDismissAction": @(UNNotificationCategoryOptionCustomDismissAction),
  @"allowInCarPlay": @(UNNotificationCategoryOptionAllowInCarPlay),
}),UNNotificationCategoryOptionNone, integerValue);


+(UNNotificationCategory*)UNNotificationCategory:(id)json
{
  NSDictionary<NSString *, id> *data = [self NSDictionary:json];

  NSString* categoryIdentifier = [RCTConvert NSString:data[@"categoryIdentifier"]];
  NSArray<UNNotificationAction*>* actions = [RCTConvert UNNotificationActionArray:data[@"actions"]];
  NSArray<NSString*>* intentIds = [RCTConvert NSStringArray:data[@"intentIds"]];
  UNNotificationCategoryOptions options = [RCTConvert UNNotificationCategoryOptions:data[@"options"]];
 
  UNNotificationCategory* category = [UNNotificationCategory categoryWithIdentifier:categoryIdentifier
                                                             actions:actions
                                                             intentIdentifiers:intentIds
                                                             options:options];
  return category;
}

RCT_ARRAY_CONVERTER(UNNotificationCategory);

@end
