//
//  GTCreateRideController.h
//  goTogether
//
//  Created by shirish on 27/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "TABaseViewController.h"
#import "Event.h"

@interface GTCreateRideController : TABaseViewController
@property (nonatomic, assign) GTEventMode eventMode;
@property (nonatomic, strong) Event *event;
@end
