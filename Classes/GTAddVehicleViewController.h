//
//  GTAddVehicleViewController.h
//  goTogether
//
//  Created by Shirish on 1/5/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "TABaseTableViewController.h"

@protocol GTAddVehicleDelegate <NSObject>
- (void)vehicleDetailsAddedSuccessfully;
- (void)editVehicleSuccessful;
@end

@interface GTAddVehicleViewController : TABaseTableViewController
@property (nonatomic, strong) Vehicle *vehicle;
@property (nonatomic, strong) id <GTAddVehicleDelegate> delegate;
@end
