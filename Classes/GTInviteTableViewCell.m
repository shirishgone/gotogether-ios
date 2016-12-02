//
//  GTInviteTableViewCell.m
//  goTogether
//
//  Created by shirish gone on 05/03/15.
//  Copyright (c) 2015 gotogether. All rights reserved.
//

#import "GTInviteTableViewCell.h"
#import "GTInviteContact.h"

@interface GTInviteTableViewCell()

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *phoneNumberLabel;
@property (nonatomic, strong) IBOutlet UIButton *inviteButton;

@end

@implementation GTInviteTableViewCell

- (void)setContactDict:(GTInviteContact *)contactDict {
    _contactDict = contactDict;
    
    [self.nameLabel setText:contactDict.name];
    [self.phoneNumberLabel setText:contactDict.phoneNumber];
    [self setButtonStatus];
}

- (IBAction)inviteButtonTouched:(id)sender {
    self.contactDict.isInvited = YES;
    [self setButtonStatus];
    
    if ([self.delegate respondsToSelector:@selector(inviteContact:)]) {
        [self.delegate inviteContact:_contactDict];
    }
}

- (void)setButtonStatus {
    if (self.contactDict.isInvited == NO) {
        [self.inviteButton setHidden:NO];
        [self setAccessoryType:UITableViewCellAccessoryNone];
    }else{
        [self.inviteButton setHidden:YES];
        [self setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

@end
