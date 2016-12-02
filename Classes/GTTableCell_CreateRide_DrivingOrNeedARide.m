//
//  GTTableCellRiderSelector.m
//  goTogether
//
//  Created by shirish on 28/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTTableCell_CreateRide_DrivingOrNeedARide.h"
@interface GTTableCell_CreateRide_DrivingOrNeedARide()
- (IBAction)segmentControlChanged:(id)sender;
@end


@implementation GTTableCell_CreateRide_DrivingOrNeedARide
- (IBAction)segmentControlChanged:(id)sender{
    
    GTUserType userType;
    if(_segmentControl.selectedSegmentIndex == 0){
        userType = userType_passenger;
    }else{
        userType = userType_driving;
    }
    
    if ([_delegate respondsToSelector:@selector(rideTypeSelected:)]) {
        [_delegate rideTypeSelected:userType];
    }
}

- (void)setUserType:(GTUserType)userType{
    if (userType == userType_driving) {
        [self.segmentControl setSelectedSegmentIndex:1];
    }else if(userType == userType_passenger){
        [self.segmentControl setSelectedSegmentIndex:0];
    }
}
@end
