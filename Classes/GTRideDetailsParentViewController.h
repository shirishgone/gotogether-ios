//
//  GTRideDetailsParentViewController.h
//  goTogether
//
//  Created by shirish gone on 07/07/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTRideDetailsParentViewController : TABaseViewController

@property (strong, nonatomic) Event *event;

@property (nonatomic, readwrite) BOOL isPresented;

- (void)updateEvent ;

- (void)pushToShowUserWithId:(NSString *)userId ;

@end
