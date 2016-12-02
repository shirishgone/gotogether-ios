//
//  GTRideDetailsActionCell.h
//  goTogether
//
//  Created by shirish on 30/06/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol GTRideDetailsActionCellDelegate <NSObject>
- (void)requestRideTouched;
@end

@interface GTRideDetailsActionCell : UITableViewCell
@property (nonatomic, assign) id <GTRideDetailsActionCellDelegate> delegate;
@property (nonatomic, strong) Event *eventDetails;
@end
