//
//  TATripComment.h
//  goTogether
//
//  Created by shirish on 02/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TATripComment : NSObject
@property (nonatomic, strong) NSString *commentString;
@property (nonatomic, strong) NSString *commentedUserId;
@property (nonatomic, strong) NSString *tripCreatorUserId;
@end
