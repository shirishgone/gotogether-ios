//
//  GTProfileTableCell_Vehicle.m
//  goTogether
//
//  Created by Shirish on 2/2/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTProfileVehicleTableCell.h"
@interface GTProfileVehicleTableCell()

@property (nonatomic, weak) IBOutlet UILabel *vehicleLabel;

@end


@implementation GTProfileVehicleTableCell

- (void)setVehicle:(Vehicle *) vehicle {
    if (vehicle != nil) {
        NSString *vehicleString = [NSString stringWithFormat:@"%@ %@",vehicle.make, vehicle.model];
        [self.vehicleLabel setText:vehicleString];
    }else {
        [self.vehicleLabel setText:@"Not Available"];
    }
}

@end
