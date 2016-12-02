//
//  GTTwitterManager.h
//  goTogether
//
//  Created by Shirish on 3/7/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTTwitterManager : NSObject

+(GTTwitterManager*)sharedInstance;

- (void)shareOnTwitterWithMessage:(NSString *)message;
    

@end
