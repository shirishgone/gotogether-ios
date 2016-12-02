//
//  GTInviteTableViewCell.h
//  goTogether
//
//  Created by shirish gone on 05/03/15.
//  Copyright (c) 2015 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GTInviteContact;

@protocol GTInviteTableViewCellDelegate <NSObject>

- (void)inviteContact:(GTInviteContact *)contact;

@end

@interface GTInviteTableViewCell : UITableViewCell

@property (nonatomic, strong) GTInviteContact *contactDict;
@property (nonatomic, weak) id <GTInviteTableViewCellDelegate> delegate;

@end
