//
//  RCUserNotificationEvents.m
//  MoneyInbox
//
//  Created by Seraj Ahmad on 10/19/16.
//  Copyright © 2016 Clzor Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNUserNotificationEvents.h"

@implementation RNUserNotificationEvent {
  NSMutableArray<NSDictionary*>* nxQueue;
  UNNotificationResponse* initialResponse;
  BOOL eventHandlerRegistered;
}

-(id)init {
  self = [super init];
  if(self) {
    nxQueue = [[NSMutableArray alloc] init];
    eventHandlerRegistered = NO;
    initialResponse = nil;
  }
  return self;
}

+ (id)shared {
  static RNUserNotificationEvent *sharedEventManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedEventManager = [[self alloc] init];
  });
  return sharedEventManager;
}

- (void)dealloc {
  // Should never be called, but just here for clarity really.
}

-(void)postEvent:(NSNotificationName)eventName userInfo:(NSDictionary*)userInfo
{
  if(eventHandlerRegistered) {
    NSLog(@"PUSH posting event %@ with data %@", eventName, userInfo);
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName
                                                        object:self
                                                      userInfo:userInfo];
  } else if([eventName isEqualToString:@"NotificationResponseReceived"] && !initialResponse) {
    initialResponse = userInfo[@"response"];
  } else {
    NSLog(@"PUSH buffering event %@ with data %@", eventName, userInfo);
    [nxQueue addObject:@{@"name": eventName, @"userInfo": userInfo}];
    
  }
}

-(void)enableEvents
{
  eventHandlerRegistered = TRUE;
  NSLog(@"PUSH: enabled event handlers. #waiting = %lul", (unsigned long)[nxQueue count]);
  for(NSDictionary* event in nxQueue) {
    NSLog(@"PUSH: waitng: %@", event[@"name"]);
  }
}

-(void)triggerWaitingNotifications
{
  NSLog(@"PUSH: trigger waiting events #waiting %lul", (unsigned long)[nxQueue count]);
  for(NSDictionary* event in nxQueue) {
    NSLog(@"PUSH: forwarding %@", event[@"name"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:event[@"name"]
                                                        object:self
                                                      userInfo:event[@"userInfo"]];
  }
  [nxQueue removeAllObjects];
}

-(UNNotificationResponse*)getInitialNotificationResponse
{
  return initialResponse;
}

@end
