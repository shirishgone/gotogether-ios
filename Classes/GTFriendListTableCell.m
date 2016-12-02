//
//  GTFriendListTableCell.m
//  goTogether
//
//  Created by shirish on 08/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTFriendListTableCell.h"
#import "UIImage+TAExtensions.h"

#define kProfilePic_width 42.0f
@interface GTFriendListTableCell()
@property (nonatomic, strong) IBOutlet UIImageView *profilePicture;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@end

@implementation GTFriendListTableCell
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
