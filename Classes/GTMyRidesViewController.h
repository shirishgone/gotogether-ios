//
//  GTMyEventsViewController.h
//  goTogether
//
//  Created by shirish on 22/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "TABaseTableViewController.h"

@interface GTMyRidesViewController : TABaseTableViewController

- (void)pushToEventDetailsWithData:(Event *)eventDetails;

@property (nonatomic, readwrite) GTMyRidesType ridesType;

@end
