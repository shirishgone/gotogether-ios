//
//  GTNotificationsManager.h
//  goTogether
//
//  Created by shirish on 18/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTNotificationsManager : NSObject

+ (GTNotificationsManager*)sharedInstance;
- (void)clearAllNotifications;
- (void)handlePushNotificationWithDetails:(NSDictionary *)userInfo;

@end
