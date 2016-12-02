//
//  GTUrbanAirshipManager.h
//  goTogether
//
//  Created by shirish gone on 29/10/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTPushNotificationManager : NSObject

+(GTPushNotificationManager*)sharedInstance;

- (void)updatePushToken ;

@end
