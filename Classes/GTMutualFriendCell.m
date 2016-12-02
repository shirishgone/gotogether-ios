//
//  GTMutualFriendCell.m
//  goTogether
//
//  Created by shirish gone on 15/12/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTMutualFriendCell.h"
#define kProfilePic_width 40.0f

@interface GTMutualFriendCell()
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@end

@implementation GTMutualFriendCell

- (void)setName:(NSString *)name{
    [self.nameLabel setText:name];
}

- (void)setProfilePic:(UIImage *)picture {
    if (picture != nil) {
        [self.profilePicture setImage:picture];
        [self.profilePicture.layer setCornerRadius:kProfilePic_width / 2.0];
        [self.profilePicture.layer setMasksToBounds:YES];
        [self.profilePicture.layer setBorderWidth:0.5];
        [self.profilePicture.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.profilePicture setContentMode:UIViewContentModeScaleAspectFill];
        
    }
}

@end