//
//  GTProfileViewController.h
//  goTogether
//
//  Created by shirish on 21/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "User.h"

@interface GTProfileViewController : TABaseTableViewController
<UIImagePickerControllerDelegate,
UITextViewDelegate,
UITextFieldDelegate>

@property (strong, nonatomic) User *user;

- (void)showCurrentUser;

@end
