//
//  GTUrbanAirshipManager.m
//  goTogether
//
//  Created by shirish gone on 29/10/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTPushNotificationManager.h"
static GTPushNotificationManager *sharedInstance = nil;

@interface  GTPushNotificationManager()
@end

@implementation GTPushNotificationManager

+(GTPushNotificationManager*)sharedInstance
{
    @synchronized([GTPushNotificationManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

#pragma mark - update push token
- (void)updatePushToken {
    // Update push token
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [User
     updateUserPushToken:appDelegate.deviceTokenString
     sucess:^(NSString *sucessMessage) {
         TALog(@"push token updated on server");
     } failure:^(NSError *error) {
         TALog(@"push token update failed");
     }];
}

@end