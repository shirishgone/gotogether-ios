//
//  GTDataManager.h
//  goTogether
//
//  Created by shirish on 25/11/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTDataManager : NSObject

+(GTDataManager*)sharedInstance;

- (void)cleanupDatabase;

- (NSString *)shareMessage;

@end
