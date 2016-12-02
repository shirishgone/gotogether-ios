//
//  GTAddBioViewController.h
//  goTogether
//
//  Created by shirish gone on 12/07/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "TABaseViewController.h"

@protocol GTAddBioViewControllerDelegate <NSObject>

- (void)saveUserBio:(NSString *)bioString;

@end

@interface GTAddBioViewController : TABaseViewController

@property (nonatomic, strong) NSString *bioString;
@property (nonatomic, weak) id <GTAddBioViewControllerDelegate> delegate;

@end
