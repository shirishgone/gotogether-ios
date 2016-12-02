//
//  GTNotificationsManager.m
//  goTogether
//
//  Created by shirish on 18/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTNotificationsManager.h"
#import "Event.h"
#import "Notification.h"

static GTNotificationsManager *sharedInstance = nil;

@implementation GTNotificationsManager

+ (GTNotificationsManager*)sharedInstance
{
    @synchronized([GTNotificationsManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

#pragma mark - handle notifications

- (void)clearAllNotifications {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)handlePushNotificationWithDetails:(NSDictionary *)userInfo{

    TALog(@"Push notification details: %@",userInfo);
    
    id requestValue = [userInfo valueForKey:@"request"];
    if ([requestValue isKindOfClass:[NSString class]]) {

        NSDictionary *apsDict = [userInfo valueForKey:@"aps"];
        NSString *alertMessage = [apsDict valueForKey:@"alert"];
        NSString *eventId = [userInfo valueForKey:@"eventid"];
        NSString *requestedUserId = [userInfo valueForKey:@"userid"];
        //NSString *requestedUserName = [userInfo valueForKey:@"username"];
        [self
         saveNotificationWithEventId:eventId
         userId:requestedUserId
         alertMessage:alertMessage
         andNotificationType:requestValue
         sucess:^(Notification *notification) {
             TALog(@"saving done!");

             goTogetherAppDelegate *appDelegate =
             (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
             GTRootViewController *rootViewController = appDelegate.rootViewController;
             UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
             if (applicationState == UIApplicationStateActive) {
                 [rootViewController fetchEventDetailsAndShowForNotification:notification];
             }else{
                 [rootViewController fetchEventDetailsAndShowForNotification:notification];
             }

         } failure:^(NSError *error) {

             TALog(@"saving failed!");
         }];

    }else{
        TALog(@"notification error from server");
    }
}

- (void)saveNotificationWithEventId:(NSString *)eventId
                             userId:(NSString *)userId
                       alertMessage:(NSString *)alertMessage
                andNotificationType:(NSString *)type
                             sucess:(void (^)(Notification* notification))handleSuccess
                            failure:(void (^)(NSError *error))handleFailure{
    
    [Notification
     notificationFromUserId:userId
     type:type
     eventId:eventId
     alertMessage:alertMessage
     sucess:^(Notification *notification) {
         handleSuccess(notification);
     } failure:^(NSError *error) {
         handleFailure(error);
     }];
}

@end
