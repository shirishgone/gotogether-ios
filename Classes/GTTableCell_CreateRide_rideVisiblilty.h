//
//  GTTableCell_CreateRide_ShareWith.h
//  goTogether
//
//  Created by shirish on 12/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSwitchClone.h"
#import "RCSwitchOnOff.h"
@protocol GTTableCell_CreateRide_ShareWithDelegate <NSObject>
- (void)visibilityButtonValueChanged:(GTShareWith)shareWith;
@end

@interface GTTableCell_CreateRide_rideVisiblilty : UITableViewCell <RCSwitchDelegate>
@property (nonatomic, assign) id <GTTableCell_CreateRide_ShareWithDelegate> delegate;
@property (nonatomic, weak) IBOutlet RCSwitchOnOff *visibilityControl;
@end
