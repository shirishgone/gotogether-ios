//
//  GTEditProfileViewController.h
//  goTogether
//
//  Created by shirish on 25/12/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TABaseTableViewController.h"
@protocol GTEditProfileDelegate <NSObject>

- (void)editProfileSucceeded;

@end


@interface GTEditProfileViewController : TABaseTableViewController

@property (nonatomic, assign) id <GTEditProfileDelegate> delegate;

@end
