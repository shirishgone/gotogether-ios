//
//  GTInviteContact.h
//  goTogether
//
//  Created by shirish gone on 05/03/15.
//  Copyright (c) 2015 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTInviteContact : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, readwrite) BOOL isInvited;

@end
