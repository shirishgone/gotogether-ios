//
//  GTTableCellRiderSelector.h
//  goTogether
//
//  Created by shirish on 28/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GTTableCell_CreateRide_DrivingOrNeedARideDelegate <NSObject>
- (void)rideTypeSelected:(GTUserType)userType;
@end

@interface GTTableCell_CreateRide_DrivingOrNeedARide : UITableViewCell
@property (nonatomic, assign) id <GTTableCell_CreateRide_DrivingOrNeedARideDelegate> delegate;
@property (nonatomic, weak) IBOutlet GTUserTypeSelector *segmentControl;

- (void)setUserType:(GTUserType)userType;
@end
