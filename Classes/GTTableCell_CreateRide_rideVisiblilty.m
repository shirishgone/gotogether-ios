//
//  GTTableCell_CreateRide_ShareWith.m
//  goTogether
//
//  Created by shirish on 12/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTTableCell_CreateRide_rideVisiblilty.h"
@implementation GTTableCell_CreateRide_rideVisiblilty

- (void)awakeFromNib{
    [_visibilityControl setDelegate:self];
    [_visibilityControl.offText setText:@"Public"];
    [_visibilityControl.onText setText:@"Friends"];
}

- (void)switchValueChanged{
    if ([_delegate respondsToSelector:@selector(visibilityButtonValueChanged:)]) {
        if ([_visibilityControl isOn] == YES) {
            [_delegate visibilityButtonValueChanged:shareWith_friends];
        }else{
            [_delegate visibilityButtonValueChanged:shareWith_everybody];
        }
    }
}
@end
