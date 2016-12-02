//
//  GTTableCell_CreateRide_facebookShare.h
//  goTogether
//
//  Created by shirish on 21/06/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSwitchClone.h"

@protocol GTTableCell_CreateRide_facebookShare_delegate <NSObject>
- (void)facebookButtonValueChanged:(BOOL)enabled;
@end

@interface GTTableCell_CreateRide_facebookShare : UITableViewCell
@property (nonatomic, assign) id <GTTableCell_CreateRide_facebookShare_delegate> delegate;
@end
