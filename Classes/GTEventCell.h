//
//  GTImPassengerCell.h
//  goTogether
//
//  Created by shirish on 18/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface GTEventCell : UITableViewCell
@property (nonatomic, strong) Event *event;
@property (nonatomic, assign) GTEventCellType cellType;
@end
