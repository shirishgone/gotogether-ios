//
//  GTProfileMutualFriendsTableViewCell.m
//  goTogether
//
//  Created by shirish gone on 13/09/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTProfileSocialProfileTableViewCell.h"

@interface GTProfileSocialProfileTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *mutualFriendsLabel;

- (IBAction)facebookButtonTouched:(id)sender;

@end


@implementation GTProfileSocialProfileTableViewCell

- (void)setIsCurrentUser:(BOOL)isCurrentUser andMutualFriendsCount:(int)count{
    if (isCurrentUser) {
        [self.mutualFriendsLabel setText:[NSString stringWithFormat:@"Friends (%d)",count]];
    }else{
        [self.mutualFriendsLabel setText:[NSString stringWithFormat:@"Mutual Friends (%d)",count]];
    }
}

- (IBAction)facebookButtonTouched:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(facebookButtonTouched)]) {
        [_delegate facebookButtonTouched];
    }
}

@end
