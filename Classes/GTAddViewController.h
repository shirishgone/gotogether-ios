//
//  GTAddViewController.h
//  goTogether
//
//  Created by shirish on 13/08/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GTDeleteEventDelegate <NSObject>
- (void)eventDeleted;
@end

@interface GTAddViewController : TABaseTableViewController
@property (nonatomic, strong) Event *event;
@property (nonatomic, assign) GTEventMode eventMode;
@property (nonatomic, assign) id <GTDeleteEventDelegate> delegate;
@end
