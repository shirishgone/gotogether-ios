//
//  GTProfileMutualFriendsTableViewCell.h
//  goTogether
//
//  Created by shirish gone on 13/09/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMutualFriendsView.h"

@protocol GTProfileSocialProfileTableViewCellDelegate <NSObject>

- (void)facebookButtonTouched;

@end


@interface GTProfileSocialProfileTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet GTMutualFriendsView *mutualFriendsView;

@property (nonatomic, weak) IBOutlet id <GTProfileSocialProfileTableViewCellDelegate> delegate;

- (void)setIsCurrentUser:(BOOL)isCurrentUser andMutualFriendsCount:(int)count;

@end
